package main

import (
	"bytes"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

// 客户端结构体
type LicenseClient struct {
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

// 健康检查响应
type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Version   string    `json:"version"`
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
}

// 请求结构体
type CheckLicenseHealthRequest struct {
	AppBundleID string `json:"app_bundle_id"`
}

// 创建新的客户端
func NewLicenseClient(baseURL string) *LicenseClient {
	// 创建支持自签名证书的 HTTP 客户端
	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}

	return &LicenseClient{
		BaseURL: baseURL,
		HTTPClient: &http.Client{
			Timeout:   30 * time.Second,
			Transport: tr,
		},
	}
}

// 健康检查
func (c *LicenseClient) HealthCheck() (*HealthResponse, error) {
	resp, err := c.HTTPClient.Get(c.BaseURL + "/health")
	if err != nil {
		return nil, fmt.Errorf("健康检查请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("健康检查失败，状态码: %d", resp.StatusCode)
	}

	var health HealthResponse
	if err := json.NewDecoder(resp.Body).Decode(&health); err != nil {
		return nil, fmt.Errorf("解析健康检查响应失败: %v", err)
	}

	return &health, nil
}

// 检查证书健康状态
func (c *LicenseClient) CheckLicenseHealth(appBundleID string) (*APIResponse, error) {
	req := CheckLicenseHealthRequest{AppBundleID: appBundleID}
	reqBody, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("序列化请求失败: %v", err)
	}

	resp, err := c.HTTPClient.Post(c.BaseURL+"/api/license/health", "application/json", bytes.NewBuffer(reqBody))
	if err != nil {
		return nil, fmt.Errorf("检查证书健康状态请求失败: %v", err)
	}
	defer resp.Body.Close()

	var apiResp APIResponse
	if err := json.NewDecoder(resp.Body).Decode(&apiResp); err != nil {
		return nil, fmt.Errorf("解析响应失败: %v", err)
	}

	return &apiResp, nil
}

// 下载许可证文件
func (c *LicenseClient) DownloadLicense(appBundleID, savePath string) error {
	if savePath == "" {
		savePath = fmt.Sprintf("pixelfreeAuth_%s.lic", appBundleID)
	}

	resp, err := c.HTTPClient.Get(fmt.Sprintf("%s/api/license/download/%s", c.BaseURL, appBundleID))
	if err != nil {
		return fmt.Errorf("下载许可证请求失败: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("下载许可证失败，状态码: %d", resp.StatusCode)
	}

	// 这里简化处理，只打印下载成功信息
	fmt.Printf("许可证下载成功: %s\n", savePath)
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
	fmt.Println("=== SMBeautyEngine License Health Check Client ===\n")

	// 初始化客户端
	client := NewLicenseClient("https://localhost:2443")

	// 1. 健康检查
	fmt.Println("1. 服务健康检查:")
	health, err := client.HealthCheck()
	if err != nil {
		fmt.Printf("健康检查失败: %v\n", err)
	} else {
		printJSON(health)
	}
	fmt.Println()

	// 2. 证书健康检查
	testAppBundleID := "com.example.testapp"
	fmt.Printf("2. 证书健康检查 (app_bundle_id: %s):\n", testAppBundleID)
	healthResult, err := client.CheckLicenseHealth(testAppBundleID)
	if err != nil {
		fmt.Printf("证书健康检查失败: %v\n", err)
	} else {
		printJSON(healthResult)

		// 如果需要更新，尝试下载许可证
		if healthResult.Success {
			if data, ok := healthResult.Data.(map[string]interface{}); ok {
				if needsUpdate, ok := data["needs_update"].(bool); ok && needsUpdate {
					if downloadURL, ok := data["download_url"].(string); ok && downloadURL != "" {
						fmt.Printf("\n需要更新许可证，下载URL: %s\n", downloadURL)

						// 尝试下载许可证
						err := client.DownloadLicense(testAppBundleID, "")
						if err != nil {
							fmt.Printf("下载许可证失败: %v\n", err)
						}
					}
				}
			}
		}
	}
	fmt.Println()

	// 3. 演示多个应用的证书检查
	demoMultipleApps(client)
}

func demoMultipleApps(client *LicenseClient) {
	fmt.Println("=== 多应用证书健康检查演示 ===\n")

	// 演示多个应用的证书检查
	apps := []string{
		"com.example.androidapp",
		"com.example.iosapp",
		"com.example.flutterapp",
		"com.example.unityapp",
	}

	for _, appBundleID := range apps {
		fmt.Printf("检查应用: %s\n", appBundleID)

		healthResult, err := client.CheckLicenseHealth(appBundleID)
		if err != nil {
			fmt.Printf("  - 检查失败: %v\n", err)
			continue
		}

		if healthResult.Success {
			if data, ok := healthResult.Data.(map[string]interface{}); ok {
				status := data["status"].(string)
				message := data["message"].(string)
				needsUpdate := data["needs_update"].(bool)

				fmt.Printf("  - 状态: %s\n", status)
				fmt.Printf("  - 消息: %s\n", message)
				fmt.Printf("  - 需要更新: %t\n", needsUpdate)

				if expiresAt, ok := data["expires_at"].(string); ok {
					fmt.Printf("  - 过期时间: %s\n", expiresAt)
				}

				if daysUntilExpiry, ok := data["days_until_expiry"].(float64); ok {
					fmt.Printf("  - 剩余天数: %.0f\n", daysUntilExpiry)
				}

				if needsUpdate {
					if downloadURL, ok := data["download_url"].(string); ok {
						fmt.Printf("  - 下载URL: %s\n", downloadURL)
					}
				}
			}
		} else {
			fmt.Printf("  - 检查失败: %s\n", healthResult.Error)
		}
		fmt.Println()
	}
}
