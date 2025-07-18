package main

import (
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

// 配置结构体
type Config struct {
	Port                string
	LicenseDir          string // 改为 data 目录
	PrivateKeyPath      string
	PublicKeyPath       string
	LicenseValidityDays int
	LogLevel            string
	DownloadBaseURL     string
	DataFile            string
	// HTTPS 配置
	EnableHTTPS bool
	SSLCertPath string
	SSLKeyPath  string
	HTTPPort    string
	HTTPSPort   string
}

// 许可证数据结构
type LicenseData struct {
	AppBundleID string    `json:"app_bundle_id"`
	Features    []string  `json:"features"`
	IssuedAt    time.Time `json:"issued_at"`
	ExpiresAt   time.Time `json:"expires_at"`
	Version     string    `json:"version"`
	Platform    string    `json:"platform"`
	Status      string    `json:"status"` // active, expired, disabled
	Description string    `json:"description"`
	CreatedBy   string    `json:"created_by"`
	UpdatedBy   string    `json:"updated_by"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// 完整许可证结构
type License struct {
	Data      LicenseData `json:"data"`
	Hash      string      `json:"hash"`
	Signature string      `json:"signature"`
}

// 许可证配置记录
type LicenseConfig struct {
	AppBundleID string    `json:"app_bundle_id"`
	Status      string    `json:"status"` // active, expired, disabled
	ExpiresAt   time.Time `json:"expires_at"`
	Features    []string  `json:"features"`
	Version     string    `json:"version"`
	Platform    string    `json:"platform"`
	Description string    `json:"description"`
	LicenseFile string    `json:"license_file"` // 对应的lic文件名
	CreatedBy   string    `json:"created_by"`
	UpdatedBy   string    `json:"updated_by"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// API响应结构
type APIResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
	Message string      `json:"message,omitempty"`
}

// 证书健康检查响应
type LicenseHealthResponse struct {
	AppBundleID     string    `json:"app_bundle_id"`
	NeedsUpdate     bool      `json:"needs_update"`
	ExpiresAt       time.Time `json:"expires_at"`
	DaysUntilExpiry int       `json:"days_until_expiry"`
	DownloadURL     string    `json:"download_url,omitempty"`
	Status          string    `json:"status"`
	Message         string    `json:"message"`
	Features        []string  `json:"features,omitempty"`
	Version         string    `json:"version,omitempty"`
}

// 健康检查响应
type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Version   string    `json:"version"`
}

// 请求结构体
type CheckLicenseHealthRequest struct {
	AppBundleID string `json:"app_bundle_id" binding:"required"`
	Version     string `json:"version,omitempty"`     // 客户端当前版本
	LastUpdate  string `json:"last_update,omitempty"` // 客户端最后更新时间
}

type CreateLicenseConfigRequest struct {
	AppBundleID string   `json:"app_bundle_id" binding:"required"`
	Status      string   `json:"status" binding:"required"`
	ExpiresAt   string   `json:"expires_at" binding:"required"`
	Features    []string `json:"features"`
	Version     string   `json:"version"`
	Platform    string   `json:"platform"`
	Description string   `json:"description"`
	CreatedBy   string   `json:"created_by"`
}

type UpdateLicenseConfigRequest struct {
	LicenseFile string   `json:"license_file"`
	Status      string   `json:"status"`
	ExpiresAt   string   `json:"expires_at"`
	Features    []string `json:"features"`
	Version     string   `json:"version"`
	Platform    string   `json:"platform"`
	Description string   `json:"description"`
	UpdatedBy   string   `json:"updated_by"`
}

// 贴纸项目结构体
type StickerItem struct {
	Name       string `json:"name"`       // 贴纸名称（去掉.bundle后缀）
	IconURL    string `json:"icon_url"`   // icon下载路径
	BundleURL  string `json:"bundle_url"` // bundle下载路径
	IconPath   string `json:"-"`          // 内部使用的icon文件路径
	BundlePath string `json:"-"`          // 内部使用的bundle文件路径
}

// 许可证管理器
type LicenseManager struct {
	config     *Config
	privateKey *rsa.PrivateKey
	publicKey  *rsa.PublicKey
	logger     *logrus.Logger
	configs    map[string]*LicenseConfig
	mutex      sync.RWMutex
}

// 创建新的许可证管理器
func NewLicenseManager(config *Config) (*LicenseManager, error) {
	logger := logrus.New()
	logger.SetFormatter(&logrus.JSONFormatter{})

	level, err := logrus.ParseLevel(config.LogLevel)
	if err != nil {
		level = logrus.InfoLevel
	}
	logger.SetLevel(level)

	lm := &LicenseManager{
		config:  config,
		logger:  logger,
		configs: make(map[string]*LicenseConfig),
	}

	// 确保目录存在
	if err := os.MkdirAll(config.LicenseDir, 0755); err != nil {
		return nil, fmt.Errorf("创建许可证目录失败: %v", err)
	}
	if err := os.MkdirAll(filepath.Dir(config.PrivateKeyPath), 0755); err != nil {
		return nil, fmt.Errorf("创建密钥目录失败: %v", err)
	}
	if err := os.MkdirAll(filepath.Dir(config.DataFile), 0755); err != nil {
		return nil, fmt.Errorf("创建数据目录失败: %v", err)
	}

	// 加载或生成密钥
	if err := lm.loadOrGenerateKeys(); err != nil {
		return nil, fmt.Errorf("加载密钥失败: %v", err)
	}

	// 加载配置数据
	if err := lm.loadConfigs(); err != nil {
		return nil, fmt.Errorf("加载配置失败: %v", err)
	}

	return lm, nil
}

// 加载或生成RSA密钥对
func (lm *LicenseManager) loadOrGenerateKeys() error {
	// 尝试加载现有私钥
	if _, err := os.Stat(lm.config.PrivateKeyPath); err == nil {
		// 私钥文件存在，加载它
		privateKeyBytes, err := os.ReadFile(lm.config.PrivateKeyPath)
		if err != nil {
			return fmt.Errorf("读取私钥文件失败: %v", err)
		}

		block, _ := pem.Decode(privateKeyBytes)
		if block == nil {
			return fmt.Errorf("解析私钥PEM失败")
		}

		// 尝试PKCS8格式解析
		privateKey, err := x509.ParsePKCS8PrivateKey(block.Bytes)
		if err != nil {
			// 如果PKCS8失败，尝试PKCS1格式
			privateKey, err = x509.ParsePKCS1PrivateKey(block.Bytes)
			if err != nil {
				return fmt.Errorf("解析私钥失败: %v", err)
			}
		}

		rsaPrivateKey, ok := privateKey.(*rsa.PrivateKey)
		if !ok {
			return fmt.Errorf("私钥类型错误")
		}

		lm.privateKey = rsaPrivateKey
		lm.publicKey = &rsaPrivateKey.PublicKey
		lm.logger.Info("已加载现有私钥")
	} else {
		// 生成新的密钥对
		privateKey, err := rsa.GenerateKey(rand.Reader, 2048)
		if err != nil {
			return fmt.Errorf("生成RSA密钥失败: %v", err)
		}

		// 保存私钥为PKCS8格式
		privateKeyBytes, err := x509.MarshalPKCS8PrivateKey(privateKey)
		if err != nil {
			return fmt.Errorf("序列化私钥失败: %v", err)
		}

		privateKeyPEM := pem.EncodeToMemory(&pem.Block{
			Type:  "PRIVATE KEY", // PKCS8格式的PEM类型
			Bytes: privateKeyBytes,
		})

		if err := os.WriteFile(lm.config.PrivateKeyPath, privateKeyPEM, 0600); err != nil {
			return fmt.Errorf("保存私钥失败: %v", err)
		}

		lm.privateKey = privateKey
		lm.publicKey = &privateKey.PublicKey
		lm.logger.Info("已生成新的私钥")
	}

	// 保存公钥
	publicKeyBytes := x509.MarshalPKCS1PublicKey(lm.publicKey)
	publicKeyPEM := pem.EncodeToMemory(&pem.Block{
		Type:  "RSA PUBLIC KEY",
		Bytes: publicKeyBytes,
	})

	if err := os.WriteFile(lm.config.PublicKeyPath, publicKeyPEM, 0644); err != nil {
		return fmt.Errorf("保存公钥失败: %v", err)
	}

	lm.logger.Info("已保存公钥")
	return nil
}

// 加载配置数据
func (lm *LicenseManager) loadConfigs() error {
	if _, err := os.Stat(lm.config.DataFile); os.IsNotExist(err) {
		// 配置文件不存在，创建空的配置文件
		lm.logger.Info("配置文件不存在，创建新配置文件")
		return lm.saveConfigs()
	}

	data, err := os.ReadFile(lm.config.DataFile)
	if err != nil {
		return fmt.Errorf("读取配置文件失败: %v", err)
	}

	var configs []*LicenseConfig
	if err := json.Unmarshal(data, &configs); err != nil {
		return fmt.Errorf("解析配置文件失败: %v", err)
	}

	lm.mutex.Lock()
	defer lm.mutex.Unlock()

	for _, config := range configs {
		lm.configs[config.AppBundleID] = config
	}

	lm.logger.WithField("count", len(configs)).Info("已加载许可证配置")
	return nil
}

// 保存配置数据
func (lm *LicenseManager) saveConfigs() error {
	// 注意：调用此函数时，调用者应该已经持有写锁
	// 所以这里不需要再次加锁

	var configs []*LicenseConfig
	for _, config := range lm.configs {
		configs = append(configs, config)
	}

	data, err := json.MarshalIndent(configs, "", "  ")
	if err != nil {
		return fmt.Errorf("序列化配置失败: %v", err)
	}

	if err := os.WriteFile(lm.config.DataFile, data, 0644); err != nil {
		return fmt.Errorf("保存配置文件失败: %v", err)
	}

	lm.logger.WithField("count", len(configs)).Info("已保存许可证配置")
	return nil
}

// 验证许可证
func (lm *LicenseManager) VerifyLicense(license *License) bool {
	// 检查必要字段
	if license.Data.AppBundleID == "" || license.Hash == "" || license.Signature == "" {
		return false
	}

	// 验证数据完整性
	licenseJSON, err := json.Marshal(license.Data)
	if err != nil {
		lm.logger.Error("序列化许可证数据失败")
		return false
	}

	hash := sha256.Sum256(licenseJSON)
	expectedHash := fmt.Sprintf("%x", hash)

	if expectedHash != license.Hash {
		lm.logger.Warn("许可证哈希验证失败")
		return false
	}

	// 验证签名
	signature, err := base64.StdEncoding.DecodeString(license.Signature)
	if err != nil {
		lm.logger.Error("解码签名失败")
		return false
	}

	err = rsa.VerifyPKCS1v15(lm.publicKey, crypto.SHA256, hash[:], signature)
	if err != nil {
		lm.logger.Error("签名验证失败")
		return false
	}

	// 检查过期时间
	if time.Now().UTC().After(license.Data.ExpiresAt) {
		lm.logger.Warn("许可证已过期")
		return false
	}

	return true
}

// 检查许可证健康状态
func (lm *LicenseManager) CheckLicenseHealth(appBundleID string, clientVersion string, lastUpdate string) *LicenseHealthResponse {
	lm.mutex.RLock()
	config, exists := lm.configs[appBundleID]
	lm.mutex.RUnlock()

	if !exists {
		return &LicenseHealthResponse{
			AppBundleID: appBundleID,
			Status:      "not_found",
			Message:     "未找到许可证配置",
		}
	}

	// 检查状态
	if config.Status == "disabled" {
		return &LicenseHealthResponse{
			AppBundleID: appBundleID,
			Status:      "disabled",
			Message:     "许可证已被禁用",
		}
	}

	// 检查过期时间
	daysUntilExpiry := int(time.Until(config.ExpiresAt).Hours() / 24)
	expiryNeedsUpdate := daysUntilExpiry <= 30 || daysUntilExpiry < 0

	// 检查版本是否需要更新
	versionNeedsUpdate := false
	if clientVersion != "" && config.Version != "" && clientVersion != config.Version {
		versionNeedsUpdate = true
	}

	// 检查配置更新时间
	configNeedsUpdate := false
	if lastUpdate != "" {
		if lastUpdateTime, err := time.Parse(time.RFC3339, lastUpdate); err == nil {
			// 如果客户端最后更新时间早于服务端配置更新时间，则需要更新
			if lastUpdateTime.Before(config.UpdatedAt) {
				configNeedsUpdate = true
			}
		}
	}

	// 综合判断是否需要更新
	needsUpdate := expiryNeedsUpdate || versionNeedsUpdate || configNeedsUpdate

	response := &LicenseHealthResponse{
		AppBundleID:     appBundleID,
		NeedsUpdate:     needsUpdate,
		ExpiresAt:       config.ExpiresAt,
		DaysUntilExpiry: daysUntilExpiry,
		Status:          config.Status,
		Message:         "许可证配置正常",
		Features:        config.Features,
		Version:         config.Version,
	}

	if needsUpdate {
		response.DownloadURL = fmt.Sprintf("%s/api/license/download/%s", lm.config.DownloadBaseURL, appBundleID)
		response.Status = "needs_update"

		// 根据不同的更新原因设置不同的消息
		if expiryNeedsUpdate {
			response.Message = "许可证即将过期或已过期，需要更新"
		} else if versionNeedsUpdate {
			response.Message = fmt.Sprintf("版本不匹配，服务端版本: %s，客户端版本: %s", config.Version, clientVersion)
		} else if configNeedsUpdate {
			response.Message = "服务端配置已更新，需要同步最新配置"
		}
	}

	return response
}

// 创建许可证配置
func (lm *LicenseManager) CreateLicenseConfig(req *CreateLicenseConfigRequest) error {
	// 解析过期时间
	expiresAt, err := time.Parse("2006-01-02T15:04:05Z", req.ExpiresAt)
	if err != nil {
		return fmt.Errorf("解析过期时间失败: %v", err)
	}

	// 检查是否已存在
	lm.mutex.Lock()
	defer lm.mutex.Unlock()

	if _, exists := lm.configs[req.AppBundleID]; exists {
		return fmt.Errorf("许可证配置已存在")
	}

	config := &LicenseConfig{
		AppBundleID: req.AppBundleID,
		Status:      req.Status,
		ExpiresAt:   expiresAt,
		Features:    req.Features,
		Version:     req.Version,
		Platform:    req.Platform,
		Description: req.Description,
		CreatedBy:   req.CreatedBy,
		UpdatedBy:   req.CreatedBy,
		CreatedAt:   time.Now().UTC(),
		UpdatedAt:   time.Now().UTC(),
	}

	lm.configs[req.AppBundleID] = config

	// 保存配置
	if err := lm.saveConfigs(); err != nil {
		return err
	}

	lm.logger.WithField("app_bundle_id", req.AppBundleID).Info("已创建许可证配置")
	return nil
}

// 更新许可证配置
func (lm *LicenseManager) UpdateLicenseConfig(appBundleID string, req *UpdateLicenseConfigRequest) error {
	lm.mutex.Lock()
	defer lm.mutex.Unlock()

	config, exists := lm.configs[appBundleID]
	if !exists {
		return fmt.Errorf("许可证配置不存在")
	}

	// 更新字段
	if req.Status != "" {
		config.Status = req.Status
	}
	if req.ExpiresAt != "" {
		expiresAt, err := time.Parse("2006-01-02T15:04:05Z", req.ExpiresAt)
		if err != nil {
			return fmt.Errorf("解析过期时间失败: %v", err)
		}
		config.ExpiresAt = expiresAt
	}
	if req.Features != nil {
		config.Features = req.Features
	}
	if req.Version != "" {
		config.Version = req.Version
	}
	if req.Platform != "" {
		config.Platform = req.Platform
	}
	if req.Description != "" {
		config.Description = req.Description
	}
	if req.LicenseFile != "" {
		config.LicenseFile = req.LicenseFile
	}

	config.UpdatedBy = req.UpdatedBy
	config.UpdatedAt = time.Now().UTC()

	// 保存配置
	if err := lm.saveConfigs(); err != nil {
		return err
	}

	lm.logger.WithField("app_bundle_id", appBundleID).Info("已更新许可证配置")
	return nil
}

// 删除许可证配置
func (lm *LicenseManager) DeleteLicenseConfig(appBundleID string) error {
	lm.mutex.Lock()
	defer lm.mutex.Unlock()

	if _, exists := lm.configs[appBundleID]; !exists {
		return fmt.Errorf("许可证配置不存在")
	}

	// 删除许可证文件和目录
	bundleDir := filepath.Join(lm.config.LicenseDir, appBundleID)
	if err := os.RemoveAll(bundleDir); err != nil {
		lm.logger.WithField("app_bundle_id", appBundleID).Warn("删除许可证文件失败: %v", err)
		// 继续删除配置，不因为文件删除失败而中断
	}

	delete(lm.configs, appBundleID)

	// 保存配置
	if err := lm.saveConfigs(); err != nil {
		return err
	}

	lm.logger.WithField("app_bundle_id", appBundleID).Info("已删除许可证配置和文件")
	return nil
}

// 获取许可证配置
func (lm *LicenseManager) GetLicenseConfig(appBundleID string) (*LicenseConfig, error) {
	lm.mutex.RLock()
	defer lm.mutex.RUnlock()

	config, exists := lm.configs[appBundleID]
	if !exists {
		return nil, fmt.Errorf("许可证配置不存在")
	}

	return config, nil
}

// 列出所有许可证配置
func (lm *LicenseManager) ListLicenseConfigs() []*LicenseConfig {
	lm.mutex.RLock()
	defer lm.mutex.RUnlock()

	var configs []*LicenseConfig
	for _, config := range lm.configs {
		configs = append(configs, config)
	}

	return configs
}

// 获取许可证文件路径
func (lm *LicenseManager) GetLicenseFile(appBundleID string) (string, error) {
	// 检查配置是否存在
	_, err := lm.GetLicenseConfig(appBundleID)
	if err != nil {
		return "", err
	}

	// 每个bundleid对应一个独立的pixelfreeAuth.lic文件
	filename := "pixelfreeAuth.lic"
	filepath := filepath.Join(lm.config.LicenseDir, appBundleID, filename)

	if _, err := os.Stat(filepath); os.IsNotExist(err) {
		return "", fmt.Errorf("许可证文件不存在: %s", filepath)
	}

	return filepath, nil
}

// 上传许可证文件
func (lm *LicenseManager) UploadLicenseFile(appBundleID string, filename string, file io.Reader) error {
	// 检查配置是否存在
	_, err := lm.GetLicenseConfig(appBundleID)
	if err != nil {
		return err
	}

	// 为每个bundleid创建独立的目录
	bundleDir := filepath.Join(lm.config.LicenseDir, appBundleID)
	if err := os.MkdirAll(bundleDir, 0755); err != nil {
		return fmt.Errorf("创建bundle目录失败: %v", err)
	}

	// 保存文件为pixelfreeAuth.lic
	filepath := filepath.Join(bundleDir, "pixelfreeAuth.lic")
	fileWriter, err := os.Create(filepath)
	if err != nil {
		return fmt.Errorf("创建文件失败: %v", err)
	}
	defer fileWriter.Close()

	_, err = io.Copy(fileWriter, file)
	if err != nil {
		return fmt.Errorf("保存文件失败: %v", err)
	}

	// 更新配置，记录文件路径
	updateReq := &UpdateLicenseConfigRequest{
		LicenseFile: "pixelfreeAuth.lic",
		UpdatedBy:   "system",
	}

	if err := lm.UpdateLicenseConfig(appBundleID, updateReq); err != nil {
		// 删除已上传的文件
		os.Remove(filepath)
		return err
	}

	lm.logger.WithFields(logrus.Fields{
		"app_bundle_id": appBundleID,
		"filepath":      filepath,
	}).Info("已上传许可证文件")

	return nil
}

// 获取所有贴纸列表
func (lm *LicenseManager) GetStickersList() ([]*StickerItem, error) {
	stickersDir := "Stickers"
	iconDir := filepath.Join(stickersDir, "icon")

	// 检查目录是否存在
	if _, err := os.Stat(stickersDir); os.IsNotExist(err) {
		return nil, fmt.Errorf("stickers目录不存在")
	}

	if _, err := os.Stat(iconDir); os.IsNotExist(err) {
		return nil, fmt.Errorf("stickers/icon目录不存在")
	}

	var stickers []*StickerItem

	// 读取stickers目录中的所有.bundle文件
	entries, err := os.ReadDir(stickersDir)
	if err != nil {
		return nil, fmt.Errorf("读取stickers目录失败: %v", err)
	}

	for _, entry := range entries {
		if entry.IsDir() || !strings.HasSuffix(entry.Name(), ".bundle") {
			continue
		}

		// 获取贴纸名称（去掉.bundle后缀）
		name := strings.TrimSuffix(entry.Name(), ".bundle")

		// 构建文件路径
		bundlePath := filepath.Join(stickersDir, entry.Name())
		iconPath := filepath.Join(iconDir, name+".png")

		// 检查对应的icon文件是否存在
		if _, err := os.Stat(iconPath); os.IsNotExist(err) {
			lm.logger.Warnf("贴纸 %s 对应的icon文件不存在: %s", name, iconPath)
			continue
		}

		// 构建下载URL
		baseURL := lm.config.DownloadBaseURL
		if !strings.HasSuffix(baseURL, "/") {
			baseURL += "/"
		}

		iconURL := baseURL + "api/stickers/icon/" + name + ".png"
		bundleURL := baseURL + "api/stickers/bundle/" + entry.Name()

		stickers = append(stickers, &StickerItem{
			Name:       name,
			IconURL:    iconURL,
			BundleURL:  bundleURL,
			IconPath:   iconPath,
			BundlePath: bundlePath,
		})
	}

	return stickers, nil
}

// 获取单个贴纸信息
func (lm *LicenseManager) GetStickerInfo(name string) (*StickerItem, error) {
	stickersDir := "Stickers"
	iconDir := filepath.Join(stickersDir, "icon")

	bundlePath := filepath.Join(stickersDir, name+".bundle")
	iconPath := filepath.Join(iconDir, name+".png")

	// 检查bundle文件是否存在
	if _, err := os.Stat(bundlePath); os.IsNotExist(err) {
		return nil, fmt.Errorf("贴纸bundle文件不存在: %s", name+".bundle")
	}

	// 检查icon文件是否存在
	if _, err := os.Stat(iconPath); os.IsNotExist(err) {
		return nil, fmt.Errorf("贴纸icon文件不存在: %s", name+".png")
	}

	// 构建下载URL
	baseURL := lm.config.DownloadBaseURL
	if !strings.HasSuffix(baseURL, "/") {
		baseURL += "/"
	}

	iconURL := baseURL + "api/stickers/icon/" + name + ".png"
	bundleURL := baseURL + "api/stickers/bundle/" + name + ".bundle"

	return &StickerItem{
		Name:       name,
		IconURL:    iconURL,
		BundleURL:  bundleURL,
		IconPath:   iconPath,
		BundlePath: bundlePath,
	}, nil
}

// 创建HTTP服务器
func createServer(lm *LicenseManager) *gin.Engine {
	gin.SetMode(gin.ReleaseMode)
	r := gin.New()
	r.Use(gin.Logger())
	r.Use(gin.Recovery())

	// 健康检查
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, HealthResponse{
			Status:    "healthy",
			Timestamp: time.Now().UTC(),
			Version:   "1.0.0",
		})
	})

	// API路由组
	api := r.Group("/api")
	{
		// 证书健康检查
		api.POST("/license/health", func(c *gin.Context) {
			var req CheckLicenseHealthRequest
			if err := c.ShouldBindJSON(&req); err != nil {
				c.JSON(http.StatusBadRequest, APIResponse{
					Success: false,
					Error:   "缺少app_bundle_id参数",
				})
				return
			}

			health := lm.CheckLicenseHealth(req.AppBundleID, req.Version, req.LastUpdate)
			c.JSON(http.StatusOK, APIResponse{
				Success: true,
				Data:    health,
			})
		})

		// 下载许可证文件
		api.GET("/license/download/:app_bundle_id", func(c *gin.Context) {
			appBundleID := c.Param("app_bundle_id")
			if appBundleID == "" {
				c.JSON(http.StatusBadRequest, APIResponse{
					Success: false,
					Error:   "缺少app_bundle_id参数",
				})
				return
			}

			filepath, err := lm.GetLicenseFile(appBundleID)
			if err != nil {
				c.JSON(http.StatusNotFound, APIResponse{
					Success: false,
					Error:   err.Error(),
				})
				return
			}

			c.FileAttachment(filepath, "pixelfreeAuth.lic")
		})

		// 贴纸相关接口
		// 获取所有贴纸列表
		api.GET("/stickers", func(c *gin.Context) {
			stickers, err := lm.GetStickersList()
			if err != nil {
				c.JSON(http.StatusInternalServerError, APIResponse{
					Success: false,
					Error:   err.Error(),
				})
				return
			}

			c.JSON(http.StatusOK, APIResponse{
				Success: true,
				Data:    stickers,
			})
		})

		// 获取单个贴纸信息
		api.GET("/stickers/:name", func(c *gin.Context) {
			name := c.Param("name")
			if name == "" {
				c.JSON(http.StatusBadRequest, APIResponse{
					Success: false,
					Error:   "缺少贴纸名称参数",
				})
				return
			}

			sticker, err := lm.GetStickerInfo(name)
			if err != nil {
				c.JSON(http.StatusNotFound, APIResponse{
					Success: false,
					Error:   err.Error(),
				})
				return
			}

			c.JSON(http.StatusOK, APIResponse{
				Success: true,
				Data:    sticker,
			})
		})

		// 下载贴纸icon
		api.GET("/stickers/icon/:name.png", func(c *gin.Context) {
			name := c.Param("name")
			if name == "" {
				c.JSON(http.StatusBadRequest, APIResponse{
					Success: false,
					Error:   "缺少贴纸名称参数",
				})
				return
			}

			sticker, err := lm.GetStickerInfo(name)
			if err != nil {
				c.JSON(http.StatusNotFound, APIResponse{
					Success: false,
					Error:   err.Error(),
				})
				return
			}

			c.FileAttachment(sticker.IconPath, name+".png")
		})

		// 下载贴纸bundle
		api.GET("/stickers/bundle/:filename", func(c *gin.Context) {
			filename := c.Param("filename")
			if filename == "" {
				c.JSON(http.StatusBadRequest, APIResponse{
					Success: false,
					Error:   "缺少文件名参数",
				})
				return
			}

			// 检查文件名是否以.bundle结尾
			if !strings.HasSuffix(filename, ".bundle") {
				c.JSON(http.StatusBadRequest, APIResponse{
					Success: false,
					Error:   "文件名必须以.bundle结尾",
				})
				return
			}

			// 获取贴纸名称（去掉.bundle后缀）
			name := strings.TrimSuffix(filename, ".bundle")

			sticker, err := lm.GetStickerInfo(name)
			if err != nil {
				c.JSON(http.StatusNotFound, APIResponse{
					Success: false,
					Error:   err.Error(),
				})
				return
			}

			c.FileAttachment(sticker.BundlePath, filename)
		})

		// 管理接口
		admin := api.Group("/admin")
		{
			// 创建许可证配置
			admin.POST("/license/config", func(c *gin.Context) {
				var req CreateLicenseConfigRequest
				if err := c.ShouldBindJSON(&req); err != nil {
					c.JSON(http.StatusBadRequest, APIResponse{
						Success: false,
						Error:   "参数错误",
					})
					return
				}

				if err := lm.CreateLicenseConfig(&req); err != nil {
					c.JSON(http.StatusInternalServerError, APIResponse{
						Success: false,
						Error:   err.Error(),
					})
					return
				}

				c.JSON(http.StatusOK, APIResponse{
					Success: true,
					Message: "许可证配置创建成功",
				})
			})

			// 更新许可证配置
			admin.PUT("/license/config/:app_bundle_id", func(c *gin.Context) {
				appBundleID := c.Param("app_bundle_id")
				var req UpdateLicenseConfigRequest
				if err := c.ShouldBindJSON(&req); err != nil {
					c.JSON(http.StatusBadRequest, APIResponse{
						Success: false,
						Error:   "参数错误",
					})
					return
				}

				if err := lm.UpdateLicenseConfig(appBundleID, &req); err != nil {
					c.JSON(http.StatusInternalServerError, APIResponse{
						Success: false,
						Error:   err.Error(),
					})
					return
				}

				c.JSON(http.StatusOK, APIResponse{
					Success: true,
					Message: "许可证配置更新成功",
				})
			})

			// 获取许可证配置
			admin.GET("/license/config/:app_bundle_id", func(c *gin.Context) {
				appBundleID := c.Param("app_bundle_id")
				config, err := lm.GetLicenseConfig(appBundleID)
				if err != nil {
					c.JSON(http.StatusNotFound, APIResponse{
						Success: false,
						Error:   err.Error(),
					})
					return
				}

				c.JSON(http.StatusOK, APIResponse{
					Success: true,
					Data:    config,
				})
			})

			// 列出所有许可证配置
			admin.GET("/license/configs", func(c *gin.Context) {
				configs := lm.ListLicenseConfigs()
				c.JSON(http.StatusOK, APIResponse{
					Success: true,
					Data:    configs,
				})
			})

			// 删除许可证配置
			admin.DELETE("/license/config/:app_bundle_id", func(c *gin.Context) {
				appBundleID := c.Param("app_bundle_id")
				if err := lm.DeleteLicenseConfig(appBundleID); err != nil {
					c.JSON(http.StatusInternalServerError, APIResponse{
						Success: false,
						Error:   err.Error(),
					})
					return
				}

				c.JSON(http.StatusOK, APIResponse{
					Success: true,
					Message: "许可证配置删除成功",
				})
			})

			// 上传许可证文件
			admin.POST("/license/upload/:app_bundle_id", func(c *gin.Context) {
				appBundleID := c.Param("app_bundle_id")
				file, header, err := c.Request.FormFile("license_file")
				if err != nil {
					c.JSON(http.StatusBadRequest, APIResponse{
						Success: false,
						Error:   "未找到许可证文件",
					})
					return
				}
				defer file.Close()

				if err := lm.UploadLicenseFile(appBundleID, header.Filename, file); err != nil {
					c.JSON(http.StatusInternalServerError, APIResponse{
						Success: false,
						Error:   err.Error(),
					})
					return
				}

				c.JSON(http.StatusOK, APIResponse{
					Success: true,
					Message: "许可证文件上传成功",
				})
			})
		}
	}

	return r
}

func main() {
	// 配置
	config := &Config{
		Port:                getEnv("PORT", "2443"),
		LicenseDir:          getEnv("LICENSE_DIR", "data"), // 改为data目录
		PrivateKeyPath:      getEnv("PRIVATE_KEY_PATH", "keys/private_key.pem"),
		PublicKeyPath:       getEnv("PUBLIC_KEY_PATH", "keys/public_key.pem"),
		LicenseValidityDays: getEnvAsInt("LICENSE_VALIDITY_DAYS", 365),
		LogLevel:            getEnv("LOG_LEVEL", "info"),
		DownloadBaseURL:     getEnv("DOWNLOAD_BASE_URL", "http://localhost:2443"),
		DataFile:            getEnv("DATA_FILE", "data/license_configs.json"),
		// HTTPS 配置
		EnableHTTPS: getEnvAsBool("ENABLE_HTTPS", false),
		SSLCertPath: getEnv("SSL_CERT_PATH", "certs/cert.pem"),
		SSLKeyPath:  getEnv("SSL_KEY_PATH", "certs/key.pem"),
		HTTPPort:    getEnv("HTTP_PORT", "1880"),
		HTTPSPort:   getEnv("HTTPS_PORT", "2443"),
	}

	// 创建许可证管理器
	lm, err := NewLicenseManager(config)
	if err != nil {
		log.Fatalf("创建许可证管理器失败: %v", err)
	}

	// 创建HTTP服务器
	r := createServer(lm)

	// 启动服务器
	if config.EnableHTTPS {
		// 检查SSL证书文件是否存在
		if _, err := os.Stat(config.SSLCertPath); os.IsNotExist(err) {
			lm.logger.Fatalf("SSL证书文件不存在: %s", config.SSLCertPath)
		}
		if _, err := os.Stat(config.SSLKeyPath); os.IsNotExist(err) {
			lm.logger.Fatalf("SSL私钥文件不存在: %s", config.SSLKeyPath)
		}

		// 启动HTTPS服务器
		httpsAddr := ":" + config.HTTPSPort
		lm.logger.WithFields(logrus.Fields{
			"port": config.HTTPSPort,
			"cert": config.SSLCertPath,
			"key":  config.SSLKeyPath,
		}).Info("启动HTTPS服务器")

		// 如果配置了HTTP端口，同时启动HTTP服务器用于重定向
		if config.HTTPPort != "" && config.HTTPPort != config.HTTPSPort {
			go func() {
				httpAddr := ":" + config.HTTPPort
				lm.logger.WithField("port", config.HTTPPort).Info("启动HTTP重定向服务器")

				// 创建HTTP重定向服务器
				httpServer := &http.Server{
					Addr: httpAddr,
					Handler: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
						// 重定向到HTTPS，使用正确的端口
						host := r.Host
						if strings.Contains(host, ":") {
							host = strings.Split(host, ":")[0]
						}
						httpsURL := "https://" + host + ":" + config.HTTPSPort + r.RequestURI
						http.Redirect(w, r, httpsURL, http.StatusMovedPermanently)
					}),
				}

				if err := httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
					lm.logger.WithError(err).Error("HTTP重定向服务器启动失败")
				}
			}()
		}

		// 启动HTTPS服务器
		if err := r.RunTLS(httpsAddr, config.SSLCertPath, config.SSLKeyPath); err != nil {
			log.Fatalf("启动HTTPS服务器失败: %v", err)
		}
	} else {
		// 启动HTTP服务器
		addr := ":" + config.Port
		lm.logger.WithField("port", config.Port).Info("启动HTTP服务器")

		if err := r.Run(addr); err != nil {
			log.Fatalf("启动HTTP服务器失败: %v", err)
		}
	}
}

// 辅助函数
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}

func getEnvAsBool(key string, defaultValue bool) bool {
	if value := os.Getenv(key); value != "" {
		if boolValue, err := strconv.ParseBool(value); err == nil {
			return boolValue
		}
	}
	return defaultValue
}
