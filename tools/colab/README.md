# FTY Spider JAR 逆向分析环境（Google Colab）

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/ches2010/HMTV/blob/main/tools/colab/fty_reverse_analysis.ipynb)

`fty_reverse_analysis.ipynb` 会自动：

1. 安装 JDK 17、JADX、androguard 替代解析器、pyelftools/capstone/unicorn；
2. 下载配置与其引用的 `spider` 文件并校验 MD5；
3. 展开 JAR、解析外层 DEX、JADX 反编译空壳 Spider 类；
4. 分析 ARM/AArch64 `.so` 的 ELF 信息与 JNI 符号；
5. 探测加密 `ftyshinidie.guard` 容器结构，并尝试常见 ZipCrypto 口令（预期失败）。

## 边界

Colab 是 x86_64 Linux，**不能直接运行 Android ARM 的 `.so`**，也没有 Frida/Xposed 动态环境。这个 notebook 是静态分析环境，不是解密器。详细结论见 `docs/` 中的逆向可行性报告。

## 合规

分析第三方加固/加密代码前，请确认你有权这么做。
