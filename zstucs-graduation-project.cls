\ProvidesClass{zstucs-graduation-project}

% 四种文件，默认为thesis（毕业论文）
\def\zstucs@filecode{0}
\DeclareOption{thesis}{}
\DeclareOption{translation}{\def\zstucs@filecode{1}}
\DeclareOption{review}{\def\zstucs@filecode{2}}
\DeclareOption{proposal}{\def\zstucs@filecode{3}}
\ProcessOptions\relax

% # 正文
\ifnum \zstucs@filecode=0
    % 宋体小四，行距1.5倍，字符间距标准
    %% 摘要要单独成页：要titlepage选项
    %% 左右两侧页眉还不一样：要twoside选项
    \LoadClass[zihao=-4, linespread=1.5, titlepage, twoside]{ctexart}
    %% 但内容依然保持自然高度，页面底部空白
    \raggedbottom
\else
    % 小四宋体行距1.5倍
    \LoadClass[zihao=-4, linespread=1.5]{ctexart}
\fi

% 全文所有英文字母和阿拉伯字母都用Times New Roman
% \RequirePackage{newtx}
\RequirePackage{fontspec}
\RequirePackage{amsmath}
\RequirePackage{amssymb}
\setmainfont{Times New Roman}

% # 章节标题
\ifcase \zstucs@filecode
    % 章标题：黑体三号顶格
    %% 不编号章节（目录、摘要、Abstract、致谢、参考文献）则居中
    %% 且两个字的“目录”“摘要”“致谢”，两字间空两格
    % 节标题：黑体四号顶格
    % 第三层标题：黑体小四顶格
    % 以后标题字体与正文相同，并缩进两格。
    \ctexset{
        section={
            name={第,章},
            format=\CTEXifname{\raggedright}{\centering}\heiti\zihao{3},
            titleformat=\@concludedformat
        },
        subsection/format=\heiti\zihao{4},
        subsubsection/format=\heiti,
        paragraph/format=\heiti,
        today=big
    }
    \RequirePackage{xstring}
    \newcommand\@concludedformat[1]{
        \CTEXifname{}{
        \StrLen{#1}[\@titlelength]
        \ifnum \@titlelength=2 \ziju{1} \fi
        }
        #1
    }
\or
    %% 全部同正文，一级标题加粗
    \ctexset{
        section/format+=\normalsize\raggedright,
        subsection/format+=\normalsize,
        subsubsection/format+=\mdseries
    }
\or
    \ctexset{
        % 一级标题四号黑体顶格
        % “参考文献”四号宋体加粗居中
        section/format=\zihao{4}\CTEXifname{\heiti\raggedright}{\bfseries\centering},
        % 二级标题小四黑体顶格
        subsection/format=\zihao{-4}\heiti
    }
\or
    \ctexset{
        % 一级标题：四号黑体加粗顶格
        section/format=\zihao{4}\heiti\bfseries,
        % 二级标题：小四黑体顶格
        subsection/format=\zihao{-4}\heiti,
    }
\fi

% # 目录
\ifnum \zstucs@filecode=0
    % “目  录”：黑体三号居中，两字间空两格
    % 摘  要：黑体四号顶格
    % Abstract：四号顶格
    % 章：黑体小四顶格
    % 节：宋体五号
    % 三级标题：仿宋五号
    \AtBeginEnvironment{abstract}{\addtocontents{toc}{\noindent\heiti\zihao{4}\abstractname\par}}
    \RequirePackage[titles]{tocloft}
    \renewcommand\cftsecfont{\zihao{-4}\heiti}
    \renewcommand\cftsubsecfont{\zihao{5}\songti}
    \renewcommand\cftsubsubsecfont{\zihao{5}\fangsong}
\fi

% # 标题页
\RequirePackage{pdfpages}
\RequirePackage{CJKfntef}
\RequirePackage{array}
\ifcase \zstucs@filecode
    \providecommand\class[1]{\def\@class{#1}}
    \providecommand\uid[1]{\def\@uid{#1}}
    \providecommand\supervisor[1]{\def\@supervisor{#1}}
    \renewcommand\maketitle{
    \begin{titlepage}
        \centering
        
        \vspace*{0.45cm}  
        \hspace*{-1.2cm}\includegraphics{../ZSTU.jpg}
        \vspace{35pt}
        
        % 关键：这里压缩顶部空白，让大标题立刻出现
           % ← 原来是 \vfill，这里改成固定小间距（可调 5–25mm）
        
        {\heiti\zihao{2}\hspace*{2cm} 本科毕业设计（论文）}
        
        \vspace*{22mm} 
        
        {\zihao{4}\bfseries
        \renewcommand{\arraystretch}{2.4}% 可根据需要微调 1.6~2.0
        \begin{tabular}{*2{p{4em}>{\raggedright\arraybackslash}p{0.45\textwidth-4em}}}
            \makebox[4em][s]{题目} & \multicolumn{3}{c}{\vspace{-16pt}\@title}  \\ \cline{2-4}
            \makebox[4em][s]{ } & \multicolumn{3}{c}{\vspace{-16pt} }  \\ \cline{2-4}
            \makebox[4em][s]{学院} & \multicolumn{3}{l}{\hspace{2em}\vspace{-16pt}计算机科学与技术学院（人工智能学院）} \\ \cline{2-4}
            \makebox[4em][s]{专业班级} & \multicolumn{3}{l}{\hspace{2em}\vspace{-16pt}\@class} \\ \cline{2-4} 
            \makebox[4em][s]{姓名} & {\hspace{2em}\@author} & \makebox[4em][s]{学号} & {\hspace{2em}\@uid} \\[-16pt] \cline{2-2} \cline{4-4} 
            \makebox[4em][s]{指导老师} & \multicolumn{3}{c}{\vspace{-16pt}\@supervisor} \\ \cline{2-4}
            \makebox[4em][s]{系主任} & \hspace{2em}沈炜 & \makebox[4em][s]{学院院长} & \hspace{2em}沈剑 \\[-16pt] \cline{2-2} \cline{4-4}
        \end{tabular}
        }
        
        \vspace{40pt}
        
        {\zihao{3}\bfseries \@date}
    \end{titlepage}
    
    \includepdf{../诚信声明}
    }
    % \begin{titlepage}
    %     \centering
       
    %     \includegraphics{ZSTU.jpg}
       
    %     \vfill
       
    %     {\heiti\zihao{2} 本科毕业设计（论文）}
       
    %     \vfill
       
    %     {\zihao{4}\bfseries
    %     \begin{tabular}{*2{p{4em}>{\centering\arraybackslash}p{0.5\textwidth-4em}}}
    %         \makebox[4em][s]{题目} & \multicolumn{3}{c}{@title} \ \cline{2-4}
    %         \makebox[4em][s]{学院} & \multicolumn{3}{c}{计算机科学与技术学院（人工智能学院）} \ \cline{2-4}
    %         \makebox[4em][s]{专业班级} & \multicolumn{3}{c}{@class} \ \cline{2-4}
    %         \makebox[4em][s]{姓名} & @author & \makebox[4em][s]{学号} & @uid \ \cline{2-2} \cline{4-4}
    %         \makebox[4em][s]{指导老师} & \multicolumn{3}{c}{@supervisor} \ \cline{2-4}
    %         \makebox[4em][s]{系主任} & 沈炜 & \makebox[4em][s]{学院院长} & 沈剑 \ \cline{2-2} \cline{4-4}
    %     \end{tabular}
    %     }
       
    %     \vfill
       
    %     {\zihao{3}\bfseries @date}
    % \end{titlepage}
   
    % \includepdf{诚信声明}
    % }
    
\or
    % 加译文1，黑体四号顶格
    \renewcommand\and{, }
    \renewcommand\maketitle{
    % 期刊或书籍等，年、卷、期、页码等信息，小四宋体顶格
    {\heiti\zihao{4}\raggedright 译文2\par}
    {\raggedright 作者：\@author\par}
    {\raggedright 出处：\@date\par}
    % 题目：四号黑体居中
    \begin{center}
        \zihao{4}\heiti \@title
    \end{center}
    }
\or
    \renewcommand\maketitle{
    \begin{titlepage}
        \bfseries\centering

        % 一号宋体加粗，各字间空一格
        {\zihao{1} \ziju{0.5} 文献综述}

        \vfill

        % 二号宋体加粗加下划线
        {\zihao{2} 毕业设计题目：\parbox[t]{\textwidth-7em}{\uline{\@title}}}

        \vfill
    \end{titlepage}
    
    \begin{center}
        % 毕设题目小三黑体居中
        {\zihao{-3}\heiti \@title}
        % 副标题四号黑体靠右
        
        % 综述页码从本页开始标

        % 学生姓名 小四宋体居中
        % 班级学号，小四宋体居中加括号
        \@author
    \end{center}
    }
\or
    \renewcommand\maketitle{
    \begin{titlepage}
        \bfseries\centering

        {\zihao{1} 开题报告}

        \vfill

        {\zihao{2} 毕业设计题目：\parbox[t]{\textwidth-7em}{\uline{\@title}}}

        \vfill
    \end{titlepage}

    %% 自己用Word填好传上来吧
    \includepdf{浙江理工大学本科毕业设计(论文)开题报告成绩和答辩意见}

    % 题目：三号黑体居中
    \begin{center}
        \Large\heiti \@title\\开题报告
    \end{center}
    }
\fi

% # 列表
%% 设置列表环境和正文类似的正常缩进
\RequirePackage{enumitem}
\setlist[1]{leftmargin=0pt,listparindent=\parindent}
\setlist[enumerate]{itemindent=\parindent}
\setlist[itemize]{itemindent=\parindent}
\setlist[description]{labelindent=\parindent}

% # 摘要环境
\ifnum \zstucs@filecode=0
    % “摘  要”：黑体小三居中
    % 摘要内容：宋体小四
    % “关键词”：黑体小四
    % 关键词：宋体小四，之间用分号分隔
    % 不标页码
    % “Abstract”：小三加粗居中
    % 摘要内容：小四
    % “Key words”：加粗，小四
    % 关键词：小四，之间用逗号分隔
    % 不标页码
    \RequirePackage{abstract}
    \renewcommand\abstractnamefont{\heiti\zihao{-3}\ziju{1}}
    \setlength\absparindent{\parindent}
    \AtEndEnvironment{abstract}{\vfill}
\fi

% # 浮动体
%% > 关于浮动体，提出的最多的一个问题就是：怎样让图表不要乱跑？习惯于所见即所得环境下拖曳鼠标防止图形的人尤其不适应浮动环境的“奇怪”效果。
%% > 浮动图表的目的是用浮动的位置来避免糟糕的分页，但如果不在乎图标太大而产生的分页，而要求有确定的位置，那么这其实是要求不使用“浮动环境”。
%% ————刘海洋《LaTeX入门》
\RequirePackage{float}
\floatplacement{figure}{H}
\floatplacement{table}{H}
% ## 浮动体的标题
% 图题宋体五号加粗，居中排于图的下方。
% 表题宋体五号加粗，居中排于表的上方。
\RequirePackage[font={small, bf},labelsep=space]{caption}
\captionsetup[table]{position=top}
\ifnum \zstucs@filecode=0
    % 图表按章编号（如图1-1），并写明图题，图表中文字用宋体小五
    % 表格应该尽可能是三线表。
    \counterwithin{figure}{section}
    \counterwithin{table}{section}
    \renewcommand\thefigure{\thesection-\arabic{figure}}
    \renewcommand\thetable{\thesection-\arabic{table}}
    %% 好像没用
    % \AtBeginEnvironment{figure}{\zihao{-5}}
    % \AtBeginEnvironment{table}{\zihao{-5}}
\fi

% # 公式
\ifnum \zstucs@filecode=0
    % 文章中重要的或后文将提及的公式，应用阿拉伯数字按章编号，序号加圆括号（如“(2-1)”）。
    % 公式书写应在文中另起一行，且右对齐。
    % 公式字体用五号。
    \counterwithin{equation}{section}
    \renewcommand\theequation{\thesection-\arabic{equation}}
    \allowdisplaybreaks
\fi

% 页面和页眉页脚
\ifnum \zstucs@filecode=0
    % 符合Microsoft Word习惯的页面设定
    \RequirePackage[a4paper, hmargin=1.25in, vmargin=1in]{geometry}
    % 目录部分：
    % 页码：大写罗马字母。
    % 正文部分：
    % 左侧（偶数页）页眉：“浙江理工大学本科毕业设计（论文）”，居中。
    % 右侧（奇数页）页眉：论文标题，居中。
    % 页码：阿拉伯数字。
    \RequirePackage{fancyhdr}
    \fancypagestyle{fancy}{
        \fancyhead{}
        \fancyhead[CO]{\zihao{5}\fangsong \@title}
        \fancyhead[CE]{\zihao{5}\fangsong 浙江理工大学本科毕业设计（论文）}
    }
    \preto\tableofcontents{\pagenumbering{Roman}\pagestyle{plain}}
    \appto\tableofcontents{\clearpage\pagenumbering{arabic}\pagestyle{fancy}}
\else
    \pagestyle{plain}
    %% 奇奇怪怪的页面设定
    \RequirePackage[a4paper, margin=2.5cm, left=3cm]{geometry}
\fi

% # 参考文献
% 参考文献格式注意事项：
% 起止页码中间用短横杠-
% 每篇文献结尾要用点号.
% 书籍及论文，最好标注起止页码
% 参考文献说明： 
% “参考文献”四字：黑体、三号、居中
% 具体文献：宋体五号。
% 具体内容参照GB/T 7714-2015《参考文献著录规则》（https://lib.tsinghua.edu.cn/wj/GBT7714-2015.pdf）。
% 参考文献标注法参照GB/T 7714-2015中的顺序标注法，按在正文中引出的先后次序列出，并用数字加方括号表示
% 标注在一句话结尾，必须在标点符号里面。
% 如果是两个作者，在正文中需要全部写出来，中间写“和”，外国作者写姓即可。
% 如果超过2个作者，写第1个作者，然后写“等”。如果是中国作者，写全名；如果是外国作者，写姓。
\RequirePackage[style=gb7714-2015,gbnamefmt=lowercase,doi=false,isbn=false,url=false,eprint=false]{biblatex}
\renewcommand\bibfont{\zihao{5}}

% # 附录
\ifnum \zstucs@filecode=0
    % “附录”两字：四号黑体顶格
    % 附录小标题：小四号黑体顶格
\fi

\usepackage{listings}
\usepackage{xcolor}

% 定义Python代码样式
\lstdefinestyle{pythoncode}{
    language=Python,
    basicstyle=\ttfamily\small,
    keywordstyle=\color{blue}\bfseries,
    stringstyle=\color{red},
    commentstyle=\color{gray}\itshape,
    numberstyle=\tiny\color{gray},
    numbers=left,
    numbersep=8pt,                   % 行号与代码之间的距离
    showspaces=false,
    showstringspaces=false,
    frame=single,                    % 单线边框
    rulecolor=\color{gray},
    backgroundcolor=\color{gray!5},
    tabsize=4,
    captionpos=b,
    breaklines=true,
    breakatwhitespace=true
}
