package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"time"
)

// 管理客户端结构体
type AdminClient struct {
	BaseURL    string
	HTTPClient *http.Client
}

// API响应结构
type APIResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
	Message string      `json:"message,omitempty"`
}

// 许可证配置结构
type LicenseConfig struct {
	AppBundleID string    `json:"app_bundle_id"`
	Status      string    `json:"status"`
	ExpiresAt   time.Time `json:"expires_at"`
	Features    []string  `json:"features"`
	Version     string    `json:"version"`
	Platform    string    `json:"platform"`
	Description string    `json:"description"`
	LicenseFile string    `json:"license_file"`
	CreatedBy   string    `json:"created_by"`
	UpdatedBy   string    `json:"updated_by"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// 请求结构体
type CreateLicenseConfigRequest struct {
	AppBundleID string   `json:"app_bundle_id"`
	Status      string   `json:"status"`
	ExpiresAt   string   `json:"expires_at"`
	Features    []string `json:"features"`
	Version     string   `json:"version"`
	Platform    string   `json:"platform"`
	Description string   `json:"description"`
	CreatedBy   string   `json:"created_by"`
}

type UpdateLicenseConfigRequest struct {
	Status      string   `json:"status"`
	ExpiresAt   string   `json:"expires_at"`
	Features    []string `json:"features"`
	Version     string   `json:"version"`
	Platform    string   `json:"platform"`
	Description string   `json:"description"`
	UpdatedBy   string   `json:"updated_by"`
}

// 创建新的管理客户端
func NewAdminClient(baseURL string) *AdminClient {
	return &AdminClient{
		BaseURL: baseURL,
		HTTPClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// 创建许可证配置
func (c *AdminClient) CreateLicenseConfig(req *CreateLicenseConfigRequest) error {
	reqBody, err := json.Marshal(req)
	if err != nil {
		return fmt.Errorf("序列化请求失败: %v", err)
	}

	resp, err := c.HTTPClient.Post(c.BaseURL+"/api/admin/license/config", 
		"application/json", bytes.NewBuffer(reqBody))
	if err != nil {
		return fmt.Errorf("创建许可证配置请求失败: %v", err)
	}
	defer resp.Body.Close()

	var apiResp APIResponse
	if err := json.NewDecoder(resp.Body).Decode(&apiResp); err != nil {
		return fmt.Errorf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		return fmt.Errorf("创建失败: %s", apiResp.Error)
	}

	return nil
}

// 更新许可证配置
func (c *AdminClient) UpdateLicenseConfig(appBundleID string, req *UpdateLicenseConfigRequest) error {
	reqBody, err := json.Marshal(req)
	if err != nil {
		return fmt.Errorf("序列化请求失败: %v", err)
	}

	httpReq, err := http.NewRequest("PUT", 
		fmt.Sprintf("%s/api/admin/license/config/%s", c.BaseURL, appBundleID), 
		bytes.NewBuffer(reqBody))
	if err != nil {
		return fmt.Errorf("创建请求失败: %v", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")

	resp, err := c.HTTPClient.Do(httpReq)
	if err != nil {
		return fmt.Errorf("更新许可证配置请求失败: %v", err)
	}
	defer resp.Body.Close()

	var apiResp APIResponse
	if err := json.NewDecoder(resp.Body).Decode(&apiResp); err != nil {
		return fmt.Errorf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		return fmt.Errorf("更新失败: %s", apiResp.Error)
	}

	return nil
}

// 获取许可证配置
func (c *AdminClient) GetLicenseConfig(appBundleID string) (*LicenseConfig, error) {
	resp, err := c.HTTPClient.Get(fmt.Sprintf("%s/api/admin/license/config/%s", c.BaseURL, appBundleID))
	if err != nil {
		return nil, fmt.Errorf("获取许可证配置请求失败: %v", err)
	}
	defer resp.Body.Close()

	var apiResp APIResponse
	if err := json.NewDecoder(resp.Body).Decode(&apiResp); err != nil {
		return nil, fmt.Errorf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		return nil, fmt.Errorf("获取失败: %s", apiResp.Error)
	}

	// 解析配置数据
	configData, err := json.Marshal(apiResp.Data)
	if err != nil {
		return nil, fmt.Errorf("序列化配置数据失败: %v", err)
	}

	var config LicenseConfig
	if err := json.Unmarshal(configData, &config); err != nil {
		return nil, fmt.Errorf("解析配置数据失败: %v", err)
	}

	return &config, nil
}

// 列出所有许可证配置
func (c *AdminClient) ListLicenseConfigs() ([]*LicenseConfig, error) {
	resp, err := c.HTTPClient.Get(c.BaseURL + "/api/admin/license/configs")
	if err != nil {
		return nil, fmt.Errorf("列出许可证配置请求失败: %v", err)
	}
	defer resp.Body.Close()

	var apiResp APIResponse
	if err := json.NewDecoder(resp.Body).Decode(&apiResp); err != nil {
		return nil, fmt.Errorf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		return nil, fmt.Errorf("列出失败: %s", apiResp.Error)
	}

	// 解析配置列表
	configsData, err := json.Marshal(apiResp.Data)
	if err != nil {
		return nil, fmt.Errorf("序列化配置列表失败: %v", err)
	}

	var configs []*LicenseConfig
	if err := json.Unmarshal(configsData, &configs); err != nil {
		return nil, fmt.Errorf("解析配置列表失败: %v", err)
	}

	return configs, nil
}

// 删除许可证配置
func (c *AdminClient) DeleteLicenseConfig(appBundleID string) error {
	httpReq, err := http.NewRequest("DELETE", 
		fmt.Sprintf("%s/api/admin/license/config/%s", c.BaseURL, appBundleID), nil)
	if err != nil {
		return fmt.Errorf("创建请求失败: %v", err)
	}

	resp, err := c.HTTPClient.Do(httpReq)
	if err != nil {
		return fmt.Errorf("删除许可证配置请求失败: %v", err)
	}
	defer resp.Body.Close()

	var apiResp APIResponse
	if err := json.NewDecoder(resp.Body).Decode(&apiResp); err != nil {
		return fmt.Errorf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		return fmt.Errorf("删除失败: %s", apiResp.Error)
	}

	return nil
}

// 上传许可证文件
func (c *AdminClient) UploadLicenseFile(appBundleID, filepath string) error {
	file, err := os.Open(filepath)
	if err != nil {
		return fmt.Errorf("打开文件失败: %v", err)
	}
	defer file.Close()

	// 创建multipart表单
	var buf bytes.Buffer
	writer := multipart.NewWriter(&buf)
	
	part, err := writer.CreateFormFile("license_file", filepath)
	if err != nil {
		return fmt.Errorf("创建表单文件失败: %v", err)
	}

	_, err = io.Copy(part, file)
	if err != nil {
		return fmt.Errorf("复制文件内容失败: %v", err)
	}

	writer.Close()

	// 发送请求
	resp, err := c.HTTPClient.Post(
		fmt.Sprintf("%s/api/admin/license/upload/%s", c.BaseURL, appBundleID),
		writer.FormDataContentType(),
		&buf)
	if err != nil {
		return fmt.Errorf("上传许可证文件请求失败: %v", err)
	}
	defer resp.Body.Close()

	var apiResp APIResponse
	if err := json.NewDecoder(resp.Body).Decode(&apiResp); err != nil {
		return fmt.Errorf("解析响应失败: %v", err)
	}

	if !apiResp.Success {
		return fmt.Errorf("上传失败: %s", apiResp.Error)
	}

	return nil
}

// 打印JSON响应
func printJSON(data interface{}) {
	jsonData, err := json.MarshalIndent(data, "", "  ")
	if err != nil {
		fmt.Printf("序列化JSON失败: %v\n", err)
		return
	}
	fmt.Println(string(jsonData))
}

func main() {
	fmt.Println("=== SMBeautyEngine License Admin Client ===\n")

	// 初始化管理客户端
	client := NewAdminClient("http://localhost:5000")

	// 演示许可证配置管理
	demoLicenseManagement(client)
}

func demoLicenseManagement(client *AdminClient) {
	fmt.Println("=== 许可证配置管理演示 ===\n")

	// 1. 创建许可证配置
	fmt.Println("1. 创建许可证配置:")
	createReq := &CreateLicenseConfigRequest{
		AppBundleID: "com.example.androidapp",
		Status:      "active",
		ExpiresAt:   "2025-12-31T23:59:59Z",
		Features:    []string{"beauty", "filter", "sticker"},
		Version:     "2.4.9",
		Platform:    "android",
		Description: "Android应用许可证",
		CreatedBy:   "admin",
	}

	if err := client.CreateLicenseConfig(createReq); err != nil {
		fmt.Printf("创建失败: %v\n", err)
	} else {
		fmt.Println("✅ 许可证配置创建成功")
	}
	fmt.Println()

	// 2. 创建更多配置
	configs := []*CreateLicenseConfigRequest{
		{
			AppBundleID: "com.example.iosapp",
			Status:      "active",
			ExpiresAt:   "2025-06-30T23:59:59Z",
			Features:    []string{"beauty", "filter"},
			Version:     "2.4.9",
			Platform:    "ios",
			Description: "iOS应用许可证",
			CreatedBy:   "admin",
		},
		{
			AppBundleID: "com.example.flutterapp",
			Status:      "active",
			ExpiresAt:   "2025-03-31T23:59:59Z",
			Features:    []string{"beauty", "filter", "sticker"},
			Version:     "2.4.9",
			Platform:    "flutter",
			Description: "Flutter应用许可证",
			CreatedBy:   "admin",
		},
	}

	fmt.Println("2. 批量创建许可证配置:")
	for _, config := range configs {
		if err := client.CreateLicenseConfig(config); err != nil {
			fmt.Printf("创建 %s 失败: %v\n", config.AppBundleID, err)
		} else {
			fmt.Printf("✅ %s 配置创建成功\n", config.AppBundleID)
		}
	}
	fmt.Println()

	// 3. 列出所有配置
	fmt.Println("3. 列出所有许可证配置:")
	configsList, err := client.ListLicenseConfigs()
	if err != nil {
		fmt.Printf("列出失败: %v\n", err)
	} else {
		fmt.Printf("找到 %d 个配置:\n", len(configsList))
		for _, config := range configsList {
			fmt.Printf("  - %s: %s (过期时间: %s)\n", 
				config.AppBundleID, config.Status, config.ExpiresAt.Format("2006-01-02"))
		}
	}
	fmt.Println()

	// 4. 获取特定配置
	fmt.Println("4. 获取特定许可证配置:")
	config, err := client.GetLicenseConfig("com.example.androidapp")
	if err != nil {
		fmt.Printf("获取失败: %v\n", err)
	} else {
		fmt.Println("配置详情:")
		printJSON(config)
	}
	fmt.Println()

	// 5. 更新配置
	fmt.Println("5. 更新许可证配置:")
	updateReq := &UpdateLicenseConfigRequest{
		Status:      "active",
		ExpiresAt:   "2026-12-31T23:59:59Z",
		Features:    []string{"beauty", "filter", "sticker", "background"},
		Version:     "2.5.0",
		Description: "更新后的Android应用许可证",
		UpdatedBy:   "admin",
	}

	if err := client.UpdateLicenseConfig("com.example.androidapp", updateReq); err != nil {
		fmt.Printf("更新失败: %v\n", err)
	} else {
		fmt.Println("✅ 许可证配置更新成功")
	}
	fmt.Println()

	// 6. 演示文件上传（如果有测试文件）
	fmt.Println("6. 演示许可证文件上传:")
	testFile := "test_license.lic"
	if _, err := os.Stat(testFile); err == nil {
		if err := client.UploadLicenseFile("com.example.androidapp", testFile); err != nil {
			fmt.Printf("上传失败: %v\n", err)
		} else {
			fmt.Printf("✅ 许可证文件上传成功: %s\n", testFile)
		}
	} else {
		fmt.Printf("跳过文件上传演示 (测试文件 %s 不存在)\n", testFile)
	}
	fmt.Println()

	// 7. 禁用某个配置
	fmt.Println("7. 禁用许可证配置:")
	disableReq := &UpdateLicenseConfigRequest{
		Status:    "disabled",
		UpdatedBy: "admin",
	}

	if err := client.UpdateLicenseConfig("com.example.flutterapp", disableReq); err != nil {
		fmt.Printf("禁用失败: %v\n", err)
	} else {
		fmt.Println("✅ 许可证配置已禁用")
	}
	fmt.Println()

	// 8. 最终配置列表
	fmt.Println("8. 最终许可证配置列表:")
	finalConfigs, err := client.ListLicenseConfigs()
	if err != nil {
		fmt.Printf("列出失败: %v\n", err)
	} else {
		fmt.Printf("最终配置数量: %d\n", len(finalConfigs))
		for _, config := range finalConfigs {
			fmt.Printf("  - %s: %s (过期时间: %s, 文件: %s)\n", 
				config.AppBundleID, config.Status, 
				config.ExpiresAt.Format("2006-01-02"), 
				config.LicenseFile)
		}
	}
	fmt.Println()

	// 9. 演示删除（可选）
	fmt.Println("9. 演示删除许可证配置:")
	// 注释掉删除操作，避免误删
	/*
	if err := client.DeleteLicenseConfig("com.example.flutterapp"); err != nil {
		fmt.Printf("删除失败: %v\n", err)
	} else {
		fmt.Println("✅ 许可证配置删除成功")
	}
	*/
	fmt.Println("跳过删除演示（已注释）")
	fmt.Println()

	fmt.Println("=== 许可证配置管理演示完成 ===")
} 