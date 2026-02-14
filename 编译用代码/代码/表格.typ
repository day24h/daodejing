/*
: 本文件向外暴露的函数有：
:     1. H设置数据源H: 设置要显示的版本数据。
:     2. H打印表格H: 打印指定章节的表格。
:     3. H生成单元格对象H: 在“凡例”节设置单元格对象，用于举例。
*/

#import "字符.typ": IDS, H去文本两端H, H全部章节名H
#import "单元对象.typ": H新单元对象H, H转为单元对象H
#import "共用通行字.typ": H获取共用通行字信息H
#import "../数据/尾注和补充行号.typ": H字典-补充行号H, H字典-尾注H

// 声明静态量，记录数据，全局用。
#let S数组-数据池S = state("各本数据", ()) 
#let S数组-带行号版本名S = state("记录带行号的版本名", ())
#let S打印调用次数S = counter("打印调用次数")

// 加载数据。更新静态量。
#let H设置数据源H(..I不定量参数-各本数据I) = {

  // 各本数据放进数据池。
  let I数据池I = I不定量参数-各本数据I.pos().flatten().map(
    sec_text => {IDS(sec_text).split("&")}
  )

  // 检查数组内，各元素数组中第一个元素，即章序，都能被章节名匹配。
  for sec in I数据池I {
    if H全部章节名H.filter(name => name in sec.at(0)).len() == 0 {
      panic("存在无法被匹配的数据：" + sec.join("&"))
    }
  }
  
  // 将所有字符串段，包装成“单元对象”字典。并更新静态量。
  S数组-数据池S.update(I数据池I.map(s => s.map(u => H转为单元对象H(u) )))
  
  // 记录存在行号的版本名称。并更新静态量。
  S数组-带行号版本名S.update(
    I数据池I.map(sec => sec.at(1)).dedup().map(name => {
      if "〚L" in I数据池I.filter(sec => sec.at(1) == name).flatten().join("") { 
        return name 
      } else { return none }
    }).filter(name => name != none)
  )
}

// 根据 “单元对象”，生成 tabel.cell 对象。
#let H生成单元格对象H(I单元对象I, I单元格宽I:20pt)  = {
  // 单元格属于标题列
  if "版本标题" in I单元对象I.样式标记 { return table.cell(
    text(
      size:0.7em,
      I单元对象I.正文字 + if I单元对象I.句序颜色 != "" { // 标题左侧圆点。
        place(
                left+horizon, dx:-0.46em, 
                circle(radius: 2.2pt, fill: I单元对象I.句序颜色)
             )
      } else {none})
  )}

  // 单元格属于注释列
  if "注释列" in I单元对象I.样式标记 { return table.cell(
    if not I单元对象I.样式标记.contains("列含共用通行字") or /*
    */("〈" in I单元对象I.通行字) {
       text(I单元对象I.通行字,size:0.8em)
    } else {""}
  )}

  // 单元格属于正文列
  table.cell(
    // 前景
    place( // 增加隐藏字符"_"，PDF中查找时区分单元格内字符。
      dy:0.3em,
      dx:-0.27em,
      text("_", fill: black.transparentize(100%))
    ) + /*
  */if I单元对象I.句序颜色 != "" and I单元对象I.正文字 in "▩▦🅰🅱🅲🅳🅴" { 
      text( // 句序标志上色。
            I单元对象I.正文字, fill:I单元对象I.句序颜色
          ) 
    } else if "共用通行字" in I单元对象I.样式标记{ 
      text( // 黑体。
            I单元对象I.正文字, weight: "regular",
            font:("Noto Sans CJK SC","Dao De Jing")
          )
    } else if I单元对象I.通行字.starts-with("（") and not I单元对象I
      .样式标记.contains("列含共用通行字") { 
      text( // 蓝字。
          I单元对象I.正文字, fill:rgb(blue )
          ) 
    } else if I单元对象I.通行字.starts-with("〈"){ 
      text( // 红字。
          I单元对象I.正文字, fill:rgb(red)
          ) 
    } else { 
      text(I单元对象I.正文字)
    } + /*
  */if I单元对象I.尾注 != "" { // 尾注框。
      let _stroke = (:)
      if "t" in I单元对象I.尾注 {_stroke.top = black+0.4pt}
      if "r" in I单元对象I.尾注 {_stroke.right = black+0.4pt}
      if "b" in I单元对象I.尾注 {_stroke.bottom = black+0.4pt}
      if "l" in I单元对象I.尾注 {_stroke.left = black+0.4pt}
  
      let _radius = (:)
      if "↖" in I单元对象I.尾注 {_radius.top-left = 0.1em}
      if "↗" in I单元对象I.尾注 {_radius.top-right = 0.1em}
      if "↘" in I单元对象I.尾注 {_radius.bottom-right = 0.1em}
      if "↙" in I单元对象I.尾注 {_radius.bottom-left = 0.1em}
      place(top,rect(width:100%,height:100%, stroke:_stroke, radius: _radius))
    } + /*
  */if "残字" in I单元对象I.样式标记 { // 下划线。
      place(center + bottom, dy:-10%, line(length: 76%, stroke: 0.6pt))
    } + /*
  */if "占位" in  I单元对象I.样式标记 { // 短横线。
      place(center + bottom, dy:-50% -0.3pt, line(length: 76%, stroke: 0.6pt))
    },

    // 背景图案
    fill:tiling(
        size:(I单元格宽I, I单元格宽I),
        spacing:(10pt, 10pt), 
        relative:"self", [
          #if I单元对象I.样式标记.any(x => x in("脱文", "补文")) [ // 斜线。
            #place(line(start: (0%,0%), end:(100%,100%), stroke: black+0.6pt))
          ]
          #if "衍文" in I单元对象I.样式标记 [ // 双横线。
            #place(move(dy:46%, line(length: 100%, stroke:black +0.4pt)))
            #place(move(dy:60%, line(length: 100%, stroke:black +0.4pt)))
          ]
        ])
  )
}

// 辅助 I拆成表组I
#let I合并表I(arr1, arr2) = {
  range(arr1.len()).map(l => arr1.at(l) + arr2.at(l))
}
// 辅助 I拆成表组I
#let I取列并标记注释I(I数组-同章同长I, H列H) = I数组-同章同长I.map(l => {
  l.at(H列H).样式标记.push("注释列"); (l.at(H列H),)
})
// 将表拆成表组。大表，拆成小表表组。
#let I拆成表组I(I数组-同章I, I内容列列数上限I) = {

  // 对齐各元素数组长度。去除各元素数组前两个元素：章序、版本标题。
  let I最多单元个数I = calc.max(..I数组-同章I.map(sec => sec.len()))
  let I数组-同章同长I = I数组-同章I
      .map(s=>s + range(s.len(),I最多单元个数I).map(x=>H新单元对象H())) 
      .map(x=> x.slice(2)) 

  // 声明容器，后面往里面装入数据。
  let (result, I正文侧I, I注释侧I) = /* 
  */  ( (), I数组-同章同长I.map(x => ()), I数组-同章同长I.map(x => ()) )

  // 逐列处理。
  for i in range(I数组-同章同长I.first().len()) {
    
    let (I需要注释列I, I共用通行字所在行I) = /*
    */  H获取共用通行字信息H( I数组-同章同长I.map(l => l.at(i).用于比较字) ) 

    // 含有共同通行字的列，列内单元对象的处理
    if I共用通行字所在行I != none {
      I数组-同章同长I.at(I共用通行字所在行I).at(i).样式标记.push("共用通行字")
      
      for l in range(I数组-同章同长I.len()) {
          I数组-同章同长I.at(l).at(i).样式标记.push("列含共用通行字")
      }
    } 
    // 向容器装入数据，或者拼装表。
    let I当前列数I = I正文侧I.first().len() + I注释侧I.first().len()

    if (not I需要注释列I) and I当前列数I + 1 <= I内容列列数上限I {
      // 当前列装入 `I正文侧I`
      I正文侧I = I合并表I(I正文侧I, I数组-同章同长I.map(l => (l.at(i),)))
      
    } else if (not I需要注释列I) {
      result.push(I合并表I(I正文侧I, I注释侧I)) // 两侧数据合并，并装入结果表。
      I正文侧I = I数组-同章同长I.map(_l=> (_l.at(i),)) // 重置两侧。
      I注释侧I = I数组-同章同长I.map(x => ())
      
    } else if I当前列数I + 2 <= I内容列列数上限I {
      // 当前列装入 `I正文侧I`，生成当前列的注释列，装入`I注释侧I`。
      I正文侧I = I合并表I(I正文侧I, I数组-同章同长I.map(l => (l.at(i),)))
      I注释侧I = I合并表I(I注释侧I, I取列并标记注释I(I数组-同章同长I, i))
    
    } else {
      if I当前列数I + 1 == I内容列列数上限I { // 插入空白注释列列。
        I注释侧I = I注释侧I.map(x => (H新单元对象H(样式标记:("注释列")),) + x)
      }
  
      result.push(I合并表I(I正文侧I, I注释侧I)) // 两侧数据合并，并装入结果表。
      I正文侧I = I数组-同章同长I.map(l=> (l.at(i),)) // 重置两侧。
      I注释侧I = I取列并标记注释I(I数组-同章同长I, i)
    }
  }
  // 最末表
  result.push(I合并表I(I正文侧I, I注释侧I))

  // 向各子表，添加版本标题列。
  let temp = I数组-同章I.map(x=>{ x.at(1).样式标记.push("版本标题"); (x.at(1),) })
  return result.map(tbl => I合并表I(temp, tbl))
}

// 产生用于打印表格、打印章尾行号信息的数据。
#let I产生表组数据I(H章节名H, I内容列宽I, I内容列列数上限I) = {
  // 获取同章所有数据。
  let I数组-同章I = S数组-数据池S.get().filter(sec => H章节名H in sec.at(0).正文字)
  
  // 生成章尾行号信息。
  let I打印版本行号I = I数组-同章I
      .filter(x => x.at(1).正文字 in S数组-带行号版本名S.get()) // 仅处理有行号的版本。
      .map(x => (x.at(1).正文字,)+x.slice(2).map(y => y.行号).filter(z=>z!=""))
      .map(x => // 如果版本中没有行号，则取`H字典-补充行号H`查找补充数据。
            if x.len()==1{x+(H字典-补充行号H.at(H章节名H).at(x.first()),)}
            else {x}
          )
      .map(x => 
            // 拼装用于打印的内容：
            // 如【北大】124背、124正、125、126【帛甲】93、94【帛乙】44上.
            box("【"+x.first()+"】")+h(0.4em)+x.slice(1).map(y=> box(y)).join("、")
          )
      .join(h(0.5em, weak: true)) + "."

  // 将一张大表，拆成由几张小表组成的表组。并标记通行字、追加注释列等。
  // 几张小表的表组的结构，与在PDF预览中看到的当前章表格结构一致。
  let I数组-表组数据I = I拆成表组I(I数组-同章I, I内容列列数上限I)
      
  // 句序不同于底本“单元对象”的标记颜色。    
  let I颜色集I = (
    gray,
    rgb("#86B0BD"), // 暗青
    rgb("#84994F"), // 暗绿
    rgb("#50589C"), // 暗紫
    red
  ).rev()
  
  let I当前上色I = ""
  for l in range(I数组-表组数据I.first().len()) {
    for n in range(I数组-表组数据I.len()) {
      for i in range(I数组-表组数据I.at(n).at(l).len()) {
        // 对句序不同于底本的“单元对象”标记颜色
        if I数组-表组数据I.at(n).at(l).at(i).正文字 == "▩"{I当前上色I=I颜色集I.pop()}
        I数组-表组数据I.at(n).at(l).at(i).句序颜色 = I当前上色I
        if I数组-表组数据I.at(n).at(l).at(i).正文字 == "▦"{I当前上色I = ""}

        // 将各子表首行首列的正文字设置为空字符串，不打印“校订”版本标题。
        if l == 0 and i == 0 {I数组-表组数据I.at(n).at(l).at(i).正文字 = ""}
        // 生成`tabel.cell`对象，用于填充打印对象
        I数组-表组数据I.at(n).at(l).at(i).打印对象 = H生成单元格对象H(
          I数组-表组数据I.at(n).at(l).at(i), I单元格宽I:I内容列宽I
        )
      }
    }
  }
  return (I数组-表组数据I, I打印版本行号I)
}

#let H打印表格H(I章标题内容I) = { context {
  
  // 确保作为参数的章节名，连续递增输入。如 一章、二章....
  if "第"+ I章标题内容I.text != H全部章节名H.at(S打印调用次数S.get().last()) {
    panic("没有按顺序输入章节标题：", I章标题内容I.text)
  }
  
  let I内容列宽I = 17.4pt
  let I页面不含边距宽度I = page.width - page.margin.left - page.margin.right
  let I内容列列数上限I = calc.floor((I页面不含边距宽度I -10pt)/ I内容列宽I) - 1

  // 产生关键数据，用于打印表格、打印各本行号信息的数据。
  let (I表组数据I, I打印版本行号I) = I产生表组数据I(
    "第"+I章标题内容I.text, I内容列宽I, I内容列列数上限I, 
  )

  [
    = #I章标题内容I

    // 打印章内各表
    #set text(size:11pt)
    #for n in range(I表组数据I.len()) { block( 
      fill: black.transparentize(95.33%),
      radius: 1.6pt,
      inset:5pt, // I内容列列数上限I、table.columns 中的 -10pt，是依据此。
      below: 3.6em,
      table(
        inset: 0pt,
        align: center + horizon,
        rows: range(I表组数据I.at(n).len()).map(x => I内容列宽I),
        columns:(I页面不含边距宽度I -10pt -I内容列列数上限I * I内容列宽I, //标题列宽度。
                ) + range(I表组数据I.at(n).first().len()-1).map(x => I内容列宽I),
        stroke: none,
        ..I表组数据I.at(n).flatten().map(x => x.打印对象)
      )
    )}
    
    #set text(size:0.8em)
    // 打印尾注。
    // 尾注值装在数组中，再扁平。是为了预防仅有单个尾注，漏写逗号，被识别为非数组。
    #for note in (H字典-尾注H.at("第"+I章标题内容I.text, default:()),).flatten(){
      [+ #note]
    }
    // 打印行号信息
    #I打印版本行号I
  ]
  
  } // 闭合 context
  // 辅助检查 是以章序递增的方式调用本函数。
  S打印调用次数S.step() 
  // 各章打印完毕后自动换页，除了末章。
  if I章标题内容I.text != "八十一章" {pagebreak()} 
}