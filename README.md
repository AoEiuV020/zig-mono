# Zig Mono - Zig 多模块项目（静态链接 vs 动态库对比）

Zig 多模块项目，对比静态链接与动态链接的实际差异。

## 项目结构

```
zig-mono/
├── build.zig.zon          # Zig包管理配置
├── packages/              # 库模块
│   ├── common/           # 通用库
│   │   ├── src/
│   │   │   ├── root.zig  # 业务逻辑
│   │   │   └── cshared.zig  # C导出层（动态库用）
│   │   └── build.zig
│   ├── mathlib/          # 数学计算库
│   │   ├── src/
│   │   │   ├── root.zig
│   │   │   └── cshared.zig
│   │   └── build.zig
│   └── stringlib/        # 字符串处理库
│       ├── src/
│       │   ├── root.zig
│       │   └── cshared.zig
│       └── build.zig
├── apps/
│   ├── static-app/       # 静态链接版本（直接@import Zig模块）
│   └── dynamic-app/      # 动态链接版本（extern调用.dylib）
├── scripts/
│   └── build.sh          # 构建脚本
└── build/                # 构建输出
    ├── static/
    │   └── static-app
    └── dynamic/
        ├── dynamic-app
        └── lib/
            ├── libcommon.dylib
            ├── libmathlib.dylib
            └── libstringlib.dylib
```

## 快速开始

### 构建

```bash
./scripts/build.sh
```

### 运行

```bash
# 静态链接版本
./build/static/run.sh

# 动态链接版本
./build/dynamic/run.sh
```

两个版本功能完全相同，输出结果一致。

## 构建产物对比

详见 [构建测试总结.md](md/构建测试总结.md)

### 静态链接
- **static-app**: 76K
- **总计**: 76K

### 动态链接
- **dynamic-app**: 55K
- **libcommon.dylib**: 74K
- **libmathlib.dylib**: 75K
- **libstringlib.dylib**: 75K
- **总计**: 280K

⚠️ 动态链接版本比静态链接大 **269%**

## 与Go版本对比

| 语言 | 静态链接 | 动态链接（总计） | 差异倍数 |
|------|---------|----------------|---------|
| Go   | 2.3M    | 7.4M           | 3.2x    |
| Zig  | 76K     | 280K           | 3.7x    |

**Zig的优势**：
- 静态链接小30倍（76K vs 2.3M）
- 动态链接小26倍（280K vs 7.4M）
- 无运行时开销，编译产物极其精简

## 技术要点

### Zig模块系统
- 使用`-M`参数和`--dep`定义模块依赖关系
- 第一个`-M`是主模块（程序入口）
- 模块间通过`@import("module_name")`相互引用

### 动态库生成
- 使用`zig build-lib -dynamic`生成`.dylib`（macOS）或`.so`（Linux）
- 每个库的`cshared.zig`目录包含C导出层
- C导出层通过ID映射管理Zig对象，只做类型转换

### 构建方式对比
- **静态链接**: 
  - 使用`zig build-exe`直接编译，通过`@import`引用模块
  - 单一可执行文件，体积最小
  
- **动态链接**: 
  - 先用`zig build-lib -dynamic`编译动态库
  - 再用`zig build-exe -lc -L<path> -l<lib>`链接动态库
  - 通过`extern`声明调用C接口
  - macOS使用`install_name_tool`设置`@rpath`

### 代码复用
- **业务逻辑**: 在`packages/*/src/root.zig`中实现
- **静态链接**: 直接@import Zig模块
- **动态链接**: cshared层包装Zig模块，通过extern调用

关键：两种方式执行**完全相同**的代码。

### 模块依赖
```
common (基础库)
  ↓
mathlib, stringlib (依赖 common)
  ↓
static-app (@import Zig模块)
dynamic-app (extern调用.dylib)
```

## 验证动态链接

```bash
otool -L build/dynamic/dynamic-app
```

输出应显示对三个`.dylib`的依赖。

## 架构设计

### 代码组织
1. **src/root.zig**: Zig业务逻辑实现
2. **src/cshared.zig**: C导出接口（仅用于动态库）
3. **static-app**: 直接import Zig模块
4. **dynamic-app**: extern声明 + 动态库调用

### C导出层设计
- 使用`export`关键字导出C兼容函数
- 通过`std.AutoHashMap`管理对象实例ID
- 避免直接传递Zig指针，符合C ABI
- 只做数据结构转换，核心逻辑复用root.zig

## 环境要求

- Zig 0.15+
- macOS / Linux

## 特色

1. **极致的代码复用**: C导出层只是薄薄一层包装，核心代码完全共享
2. **零运行时开销**: 相比Go，Zig编译产物小30倍
3. **真正的C ABI兼容**: 动态库可以被任何支持C FFI的语言调用
4. **模块化设计**: 使用Zig原生模块系统，无需构建工具

---

**创建日期**: 2025年11月23日

**Zig版本**: 0.15.2
测试zig多模块项目，
