---
name: flow-pilot-test
description: TDD 测试助手（多语言支持）
version: 1.0.6
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash
---

# Flow-Pilot TDD 测试驱动开发助手

## 用途

1. **独立使用：** `/flow-pilot-test src/auth.py` - 为指定文件生成测试
2. **Pilot 集成：** 在严格 TDD 模式下自动触发

## 参数

**目标文件：** $0

**模式：** $1 (可选: red | green | refactor)

---

## TDD 循环：RED → GREEN → REFACTOR

### 🔴 RED 阶段：编写失败的测试

1. **分析目标文件**
   - 读取源文件
   - 理解职责和接口
   - 识别函数/类/方法

2. **生成测试骨架**

**Python 示例：**
```python
import pytest
from src.auth import hash_password

def test_hash_password_返回bcrypt格式():
    """密码哈希应返回 bcrypt 格式的字符串"""
    password = "secure_password_123"
    hashed = hash_password(password)

    assert hashed.startswith("$2b$")
    assert len(hashed) == 60

def test_hash_password_相同密码产生不同哈希():
    """相同密码多次哈希应产生不同结果（因为 salt 随机）"""
    password = "same_password"
    hash1 = hash_password(password)
    hash2 = hash_password(password)

    assert hash1 != hash2
```

3. **运行测试（应该失败）**
   ```bash
   pytest tests/test_auth.py -v
   # 预期：FAILED（因为函数还不存在）
   ```

---

### 🟢 GREEN 阶段：实现最小代码使测试通过

1. **实现功能**
   ```python
   import bcrypt

   def hash_password(password: str) -> str:
       """使用 bcrypt 哈希密码"""
       salt = bcrypt.gensalt()
       return bcrypt.hashpw(password.encode(), salt).decode()
   ```

2. **运行测试（应该通过）**
   ```bash
   pytest tests/test_auth.py -v
   # 预期：PASSED
   ```

---

### 🔵 REFACTOR 阶段：优化代码

1. **检查可优化点**
   - 代码可读性
   - 性能优化
   - 错误处理
   - 类型注解

2. **重构并保持测试通过**
   ```python
   from typing import Optional

   def hash_password(password: str) -> str:
       """使用 bcrypt 哈希密码

       Args:
           password: 明文密码

       Returns:
           bcrypt 哈希字符串

       Raises:
           ValueError: 如果密码为空
       """
       if not password:
           raise ValueError("密码不能为空")

       salt = bcrypt.gensalt()
       return bcrypt.hashpw(password.encode(), salt).decode()
   ```

3. **补充边界测试**
   ```python
   def test_hash_password_空密码抛出异常():
       """空密码应抛出 ValueError"""
       with pytest.raises(ValueError, match="密码不能为空"):
           hash_password("")
   ```

---

## 智能测试生成

### 根据文件类型调整

**模型层（models/）：**
- 测试字段验证
- 测试关系（外键、多对多）
- 测试自定义方法

**API 层（routes/、views/）：**
- 测试请求/响应格式
- 测试状态码
- 测试认证/授权
- 测试错误处理

**工具层（utils/）：**
- 测试各种输入组合
- 测试边界条件
- 测试异常情况

### 覆盖重要场景

1. **Happy Path** - 正常流程
2. **Edge Cases** - 边界情况（空值、极大值、特殊字符）
3. **Error Handling** - 异常处理
4. **Security** - 安全相关（SQL 注入、XSS）

---

## 多语言支持

### Python
- 框架：pytest
- 文件命名：`tests/test_{module}.py` 或 `tests/{module}_test.py`
- 断言：assert
- Mock：unittest.mock, pytest-mock

### TypeScript / JavaScript
- 框架：Jest, Vitest
- 文件命名：`{module}.test.ts` 或 `{module}.spec.ts`
- 断言：expect()
- Mock：jest.fn(), vi.fn()

### Go
- 框架：testing
- 文件命名：`{module}_test.go`（同目录）
- 断言：if got != want
- Mock：testify/mock

### Rust
- 框架：内置 #[test]
- 文件命名：`tests/{module}_test.rs`
- 断言：assert_eq!, assert!
- Mock：mockall

---

## 输出格式

完成后总结：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ TDD 循环完成：src/auth.py
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔴 RED：
  ✅ 生成测试：tests/test_auth.py
  ✅ 运行测试：4 failed（符合预期）

🟢 GREEN：
  ✅ 实现代码：src/auth.py
  ✅ 运行测试：4 passed

🔵 REFACTOR：
  ✅ 优化代码：增加类型注解、错误处理
  ✅ 补充测试：新增边界测试
  ✅ 最终测试：5 passed

📊 测试覆盖率：
  src/auth.py: 100%

💡 建议：
  - 考虑添加性能测试（大批量密码哈希）
  - 可以添加集成测试（配合数据库）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 中文命名支持

测试名称可以使用中文（提高可读性）：

```python
class Test密码哈希:
    def test_哈希密码返回bcrypt格式(self):
        ...

    def test_相同密码产生不同哈希(self):
        ...
```

或使用 docstring（适合团队不接受中文标识符）：

```python
def test_hash_password_format(self):
    """哈希密码应返回 bcrypt 格式"""
    ...
```

---

## 调用契约

### 输入契约
```json
{
  "file_path": "src/auth.py",  // 必需
  "mode": "red",                // red | green | refactor | auto
  "language": "python"          // 自动检测
}
```

### 输出契约
```json
{
  "success": true,
  "test_file": "tests/test_auth.py",
  "tests_written": 5,
  "tests_passed": 5,
  "coverage": 100.0,
  "tdd_phases": {
    "red": true,
    "green": true,
    "refactor": true
  }
}
```

---

## 记住

你是**TDD 专家**，不是代码生成器：
- 🔴 先写测试，描述预期行为
- 🟢 实现最小代码使测试通过
- 🔵 重构优化，保持测试通过
- 📊 关注测试覆盖率和质量
- 💡 提供有价值的测试建议
