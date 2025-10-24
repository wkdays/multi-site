// ============================================
// 中晋数据科技 - 交互脚本
// ============================================

// 滚动渐入动画
const observerOptions = {
  threshold: 0.1,
  rootMargin: "0px 0px -50px 0px",
};

const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add("active");
    }
  });
}, observerOptions);

document.querySelectorAll(".reveal").forEach((el) => observer.observe(el));

// ============================================
// 导航栏功能 - 参考 Ecopia AI
// ============================================

// 导航栏滚动效果
window.addEventListener("scroll", () => {
  const topBar = document.querySelector(".top-bar");
  if (window.scrollY > 50) {
    topBar.classList.add("scrolled");
  } else {
    topBar.classList.remove("scrolled");
  }
});

// ============================================
// 平滑滚动 - 带导航栏偏移
// ============================================

document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
  anchor.addEventListener("click", function (e) {
    const href = this.getAttribute("href");
    if (href === "#") return;
    
    e.preventDefault();
    const target = document.querySelector(href);
    
    if (target) {
      const topBarHeight = document.querySelector(".top-bar").offsetHeight;
      const targetPosition = target.offsetTop - topBarHeight - 20;
      
      window.scrollTo({
        top: targetPosition,
        behavior: "smooth",
      });
      
      // 移动端：关闭菜单
      if (window.innerWidth <= 1024) {
        nav.classList.remove("active");
        menuToggle.setAttribute("aria-expanded", "false");
        document.body.style.overflow = "";
      }
    }
  });
});

// ============================================
// 导航高亮 - 根据滚动位置
// ============================================

const sections = document.querySelectorAll("section[id]");
const navLinks = document.querySelectorAll(".nav a[href^='#']");

window.addEventListener("scroll", () => {
  let current = "";
  
  sections.forEach((section) => {
    const sectionTop = section.offsetTop;
    const sectionHeight = section.offsetHeight;
    if (window.scrollY >= sectionTop - 150) {
      current = section.getAttribute("id");
    }
  });
  
  navLinks.forEach((link) => {
    link.classList.remove("active");
    const href = link.getAttribute("href");
    if (href === `#${current}`) {
      link.classList.add("active");
    }
  });
});

// 联系表单提交
const contactForm = document.querySelector(".contact-form");
if (contactForm) {
  contactForm.addEventListener("submit", (e) => {
    e.preventDefault();
    alert("感谢您的咨询！我们会在30分钟内与您联系。");
    contactForm.reset();
  });
}

// 聊天组件
const chatToggle = document.querySelector(".chat-toggle");
const chatPanel = document.querySelector(".chat-panel");
const chatForm = document.querySelector(".chat-form");
const chatMessages = document.querySelector(".chat-messages");

if (chatToggle && chatPanel) {
  chatToggle.addEventListener("click", () => {
    const isHidden = chatPanel.getAttribute("aria-hidden") === "true";
    chatPanel.setAttribute("aria-hidden", !isHidden);
    chatToggle.setAttribute("aria-expanded", isHidden);
    
    if (isHidden && chatMessages.children.length === 0) {
      // 添加欢迎消息
      addBotMessage(`您好！我是中晋数据科技的AI智能客服。

我可以帮您：
• 快速诊断数据故障类型
• 评估恢复可能性与时间
• 提供初步报价参考
• 推荐专业解决方案

请描述您遇到的问题，例如：
"RAID5阵列2块盘同时掉线"
"Oracle数据库误删除表"
"SSD固态硬盘无法识别"`);
    }
  });
}

if (chatForm) {
  chatForm.addEventListener("submit", (e) => {
    e.preventDefault();
    const input = chatForm.querySelector("textarea");
    const message = input.value.trim();
    
    if (message) {
      addUserMessage(message);
      input.value = "";
      
      // 模拟AI响应
      setTimeout(() => {
        const response = getAIResponse(message);
        addBotMessage(response);
      }, 1000);
    }
  });
}

function addUserMessage(text) {
  const div = document.createElement("div");
  div.style.cssText = "margin-bottom:1rem;text-align:right;";
  div.innerHTML = `<div style="display:inline-block;background:var(--primary);color:#fff;padding:0.75rem 1rem;border-radius:12px;max-width:80%;">${text}</div>`;
  chatMessages.appendChild(div);
  chatMessages.scrollTop = chatMessages.scrollHeight;
}

function addBotMessage(text) {
  const div = document.createElement("div");
  div.style.cssText = "margin-bottom:1rem;";
  div.innerHTML = `<div style="background:var(--darker);color:var(--text-muted);padding:0.75rem 1rem;border-radius:12px;border:1px solid var(--border);white-space:pre-line;">${text}</div>`;
  chatMessages.appendChild(div);
  chatMessages.scrollTop = chatMessages.scrollHeight;
}

function getAIResponse(message) {
  const msg = message.toLowerCase();
  
  // RAID相关
  if (msg.includes("raid") || msg.includes("阵列")) {
    return `【RAID阵列故障分析】

根据您的描述，我初步判断为RAID阵列故障。请提供以下信息：

1. RAID级别（0/1/5/6/10）
2. 总硬盘数量与损坏盘数
3. 阵列卡品牌型号
4. 数据容量与重要程度

💡 紧急建议：
• 立即停止重建操作
• 不要更换硬盘
• 保持断电状态
• 联系专家评估

⏱ 预估时间：4-12小时
💰 费用区间：5000-15000元
📞 紧急通道：400-668-7788`;
  }
  
  // 数据库相关
  if (msg.includes("数据库") || msg.includes("oracle") || msg.includes("mysql")) {
    return `【数据库恢复诊断】

数据库故障需要专业DBA介入。请告知：

1. 数据库类型与版本
2. 故障现象（崩溃/误删/损坏）
3. 是否有日志文件
4. 数据量大小

💡 专业建议：
• 停止一切写操作
• 保留所有日志文件
• 记录最后一次正常时间
• 不要尝试自行修复

⏱ 预估时间：6-24小时
💰 费用区间：3000-20000元
🔧 支持：Oracle/MySQL/SQL Server/PostgreSQL`;
  }
  
  // 硬盘相关
  if (msg.includes("硬盘") || msg.includes("ssd") || msg.includes("固态")) {
    return `【硬盘故障快速诊断】

请描述具体症状：
• 无法识别/检测不到
• 异响/咔哒声
• 速度极慢
• 文件损坏

🔍 关键信息：
1. 硬盘品牌型号
2. 容量大小
3. 使用年限
4. 故障前征兆

💡 应急措施：
• SSD立即断电（防TRIM）
• 机械盘避免反复通电
• 不要格式化或修复
• 保持原始状态

⏱ 预估时间：2-7个工作日
💰 费用区间：800-5000元`;
  }
  
  // 价格相关
  if (msg.includes("价格") || msg.includes("费用") || msg.includes("多少钱")) {
    return `【收费标准参考】

我们采用透明定价，不成功不收费：

📊 个人客户：
• 误删/格式化：500-1500元
• 硬盘物理故障：800-3000元
• SSD固态硬盘：1500-5000元

🏢 企业客户：
• RAID阵列：5000-15000元
• 数据库恢复：3000-20000元
• 虚拟化平台：4000-12000元
• 紧急加急：+30-50%

✅ 我们的承诺：
• 免费检测评估
• 先报价后恢复
• 不成功不收费
• 签订服务协议

详细报价需要工程师检测后确定。
立即拨打：400-668-7788`;
  }
  
  // 默认回复
  return `感谢咨询中晋数据科技！

为了更准确地帮助您，请提供：
1. 故障设备类型（硬盘/RAID/数据库等）
2. 具体故障现象
3. 数据重要程度
4. 是否紧急

您也可以：
📞 直接致电：400-668-7788
📧 发送邮件：service@zhongjindata.com
📝 填写表单：我们30分钟内回复

我们的专家团队随时待命！`;
}

// ============================================
// 移动菜单切换 - Ecopia风格
// ============================================

const menuToggle = document.querySelector(".menu-toggle");
const nav = document.querySelector(".nav");

if (menuToggle && nav) {
  menuToggle.addEventListener("click", () => {
    const isExpanded = menuToggle.getAttribute("aria-expanded") === "true";
    menuToggle.setAttribute("aria-expanded", !isExpanded);
    nav.classList.toggle("active");
    
    // 防止页面滚动
    if (!isExpanded) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
    }
  });
}

// ============================================
// 下拉菜单功能 - 桌面端悬停，移动端点击
// ============================================

const dropdownItems = document.querySelectorAll(".has-dropdown");

dropdownItems.forEach((item) => {
  // 移动端点击展开
  if (window.innerWidth <= 1024) {
    const link = item.querySelector("a");
    link.addEventListener("click", (e) => {
      if (item.querySelector(".dropdown")) {
        e.preventDefault();
        item.classList.toggle("open");
        
        // 关闭其他下拉菜单
        dropdownItems.forEach((other) => {
          if (other !== item) {
            other.classList.remove("open");
          }
        });
      }
    });
  }
});

// 窗口调整时重置菜单状态
window.addEventListener("resize", () => {
  if (window.innerWidth > 1024) {
    nav.classList.remove("active");
    menuToggle.setAttribute("aria-expanded", "false");
    document.body.style.overflow = "";
    dropdownItems.forEach((item) => item.classList.remove("open"));
  }
});

// ============================================
// 点击外部关闭菜单 - Ecopia风格
// ============================================

document.addEventListener("click", (e) => {
  // 点击导航外部时关闭移动菜单
  if (window.innerWidth <= 1024) {
    const isMenuClick = e.target.closest(".top-bar");
    if (!isMenuClick && nav.classList.contains("active")) {
      nav.classList.remove("active");
      menuToggle.setAttribute("aria-expanded", "false");
      document.body.style.overflow = "";
    }
  }
  
  // 点击下拉菜单外部时关闭
  const isDropdownClick = e.target.closest(".has-dropdown");
  if (!isDropdownClick) {
    dropdownItems.forEach((item) => item.classList.remove("open"));
  }
});

// 模式切换
const modeBtns = document.querySelectorAll(".mode-btn");
modeBtns.forEach((btn) => {
  btn.addEventListener("click", () => {
    modeBtns.forEach((b) => b.classList.remove("active"));
    btn.classList.add("active");
    
    const mode = btn.dataset.mode;
    if (mode === "human") {
      addBotMessage("正在为您转接人工客服，请稍候...\n\n工作时间：9:00-18:00\n紧急情况请拨打：400-668-7788");
    }
  });
});

console.log("中晋数据科技网站已加载完成");
