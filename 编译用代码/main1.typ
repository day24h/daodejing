/*
* 【说明】：本文件不被项目内任何其他文件使用。
* 【作用】：打印 校订本。本文件和表格使用同一数据`H数组-校订本数据H`。
* 【使用方法】：把此文件设置为预览文件。
*/

#import "数据/校订本.typ": H数组-校订本数据H
#import "代码/单元对象.typ": H转为单元对象H
#import "代码/字符.typ": H汉转阿拉伯H

#let I提取文本I(arr) = {

  let I数组-句序已恢复I = ()
  
  for I章字符串I in arr {

    let I数组-章单元对象I = I章字符串I.split("&")
         .map(x => H转为单元对象H(x)) 
  
    I数组-句序已恢复I.push(())
    
    let I在排序I = false
    let I数组-排序I = ()
    for I单元对象I in I数组-章单元对象I{
      
      if I单元对象I.正文字 == "▩" {
        I在排序I = true
        continue
      } else if I单元对象I.正文字 == "▦" {
        I在排序I = false
        I数组-句序已恢复I.last() += I数组-排序I
          .sorted(key: x => x.first().正文字)
          .map(x => x.slice(1)).flatten() 
        I数组-排序I = ()
        continue
      }

      if I在排序I and I单元对象I.正文字 != "" and /*
      */ I单元对象I.正文字 in "🅰🅱🅲🅳🅴" {
        I数组-排序I.push((I单元对象I,))
        
      } else if I在排序I {
        I数组-排序I.last().push(I单元对象I)
        
      } else {
        I数组-句序已恢复I.last().push(I单元对象I)
      }
    }
  }
  return I数组-句序已恢复I.map(x => 
    (x.first().正文字, x.slice(2).map(y => y.正文字 + y.行号).join(""))
  )
}

#set text(font:("Noto Serif CJK SC",), size:12pt,)
#set par(spacing: 1.2em, leading: 1.2em, justify: true )
#set page(paper:"a4", margin:(x:3.2cm, y:2.54cm), numbering:"1",)

#show heading.where(level:1) : it => [
  #set text(size:10pt,weight:"regular"); 
  #box(it, fill: silver, radius: 1.2pt, inset: (x:2pt, y:1pt))
]
#show regex("🌱") :it => {
  text(font:"Noto Color Emoji", it, top-edge:1pt, baseline: -0.06em)
}

#table(
  columns: (2.2em, 1fr),
  inset: (x:0%, y:1em),
  stroke: none,
  ..I提取文本I(H数组-校订本数据H).map(x =>
    ( 
      heading(level: 1, "S"+H汉转阿拉伯H(x.first().replace(regex("第|章"),""))),
      x.last()
    )
  ).flatten()
)


