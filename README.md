# s21-kvm-kernel

三星 Galaxy S21 SM-G9910 国行 Android 15 KVM 内核编译（GitHub Codespaces）。

## 使用步骤

1. 在 GitHub Codespaces 中打开本仓库，选择 16 核的机器配置。
2. 将 `SM-G9910_CHN_15_Opensource.zip` 和 `SM-G9910_CHN_15_Opensource_G9910ZCSGHZB1_G9910ZCUGHZE1.zip` 上传到 Codespace 中。
3. 在终端中运行：

   ```bash
   ./build.sh
   ```

## 仓库内容

- `build.sh`：内核编译脚本。
- `.devcontainer/devcontainer.json`：Codespaces 开发容器配置。
