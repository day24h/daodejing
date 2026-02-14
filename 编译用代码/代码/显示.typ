/*
: 本文件向外暴露的变量有：
:     1. H字典-显示配置H: 用于各区域的show设置。
*/

// 以字典的形式存放着 文档各处用到的 show 设置。
// 用法 show:H字典-显示配置H.字典键 
#let H字典-显示配置H = (
  
    "缺省页设置-text-page-par-others": momodoc => {
      
      // 指定如下字符的使用字体。
      show regex("[◍▁∟■●〈〉（）]") : it => {
        text(font:("Dao De Jing"), it)
      }
      show regex("[🅰-🅴]|▩|▦"): it => [
        #set text(font:("Noto Sans CJK SC"), size:1em); #it
      ]

      // 全局文本设置。
      set text(
          font: ("Noto Serif CJK SC", "Dao De Jing"),
          weight:"regular",
          fallback:true,
          size:11pt,
          lang:"zh",
          cjk-latin-spacing:none
      )

      // 全局页面设置。
      set page(
          paper:"a4", 
          margin:(x:3.2cm, y:2.54cm), 
          numbering:"1",
      )

      // 全局段落设置。
      set par(
        first-line-indent: (amount: 0pt, all: true), 
        leading: 1em, 
        justify:true
      )
      
      // 一级标题设置。
      show heading.where(level:1) : it => {
          pad(top:0em, bottom:1em)[#align(center)[#text(size:16pt, weight: "light", it.body)]]
      }

      // 关闭 "" 在中文环境中自动打印为“”的功能。
      set smartquote(enabled: false)
      
      momodoc
    },

    "说明页设置": momodoc => { momodoc },
    "表格页设置": momodoc => {
      // 页面高度自动适应内容，直到遇到pagebreak() 才换页。
      set page(height: auto) 
      momodoc 
    }
)