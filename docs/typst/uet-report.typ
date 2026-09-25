// UET báo cáo template (Typst)
// Tái tạo trang bìa từ uet-graduation-latex
// (https://github.com/leduyquang753/uet-graduation-latex, MIT © Lê Duy Quang).
// Font thân: Liberation Serif (tương thích Times New Roman).

#let logo = "assets/uet-logo.pdf"

// Khung viền kép (bản sao logic coverpage của .cls).
#let uet-borders(outer: 3pt, inner: 1pt) = {
  place(dx: 25mm, dy: 20mm, rect(width: 170mm, height: 252mm, stroke: outer + black))
  place(dx: 26.5mm, dy: 21.5mm, rect(width: 157mm, height: 249mm, stroke: inner + black))
}

// Tiêu đề trường (dùng chung 2 bìa).
#let uet-school = align(center)[
  #text(12pt, weight: "bold")[ĐẠI HỌC QUỐC GIA HÀ NỘI]
  #v(2pt)
  #text(12pt, weight: "bold")[TRƯỜNG ĐẠI HỌC CÔNG NGHỆ]
]

// Bảng thành viên nhóm.
#let uet-members(members) = table(
  align: center,
  columns: (1.4fr, 1fr),
  table.header([
    #text(12pt, weight: "bold")[Họ và tên]
  ], [
    #text(12pt, weight: "bold")[Mã SV]
  ]),
  ..members.map(m => ([#text(12pt)[#m.at(0)]], [#text(12pt)[#m.at(1)]])).flatten(),
)

// Khối nội dung bên trong khung (đặt tuyệt đối so với khung bìa).
#let uet-inner(body) = place(
  dx: 30mm,
  dy: 28mm,
  block(width: 150mm, height: 236mm, [ #body ]),
)

// ===== BÌA 1: bìa chính =====
#let uet-cover1(
  title: "",
  document-type: "BÀI TẬP LỚN",
  major: "Công nghệ kỹ thuật điều khiển và tự động hoá",
  major-en: "Control Engineering and Automation",
  semester: "Học kỳ I năm học 2026-2027",
  year: 2026,
  members: (),
) = {
  page(margin: 0pt, header: none, footer: none, numbering: none)[
    #block(width: 210mm, height: 297mm)[
      #uet-borders()
      #uet-inner[
        #uet-school
        #v(1.2cm)
        #align(center)[
          #image(logo, width: 52mm)
        ]
        #v(1.2cm)
        #align(center)[
          #text(14pt, weight: "bold")[#upper(document-type)]
        ]
        #v(0.6cm)
        #align(center)[
          #text(18pt, weight: "bold")[#upper(title)]
        ]
        #v(1.0cm)
        #align(center)[
          #text(12pt)[Ngành: #major]
          #v(3pt)
          #text(12pt)[#major-en]
        ]
        #v(1fr)
        #align(center)[
          #if members.len() > 0 [
            #text(12pt, weight: "bold")[Nhóm sinh viên thực hiện]
            #v(4pt)
            #uet-members(members)
          ]
        ]
        #v(1fr)
        #align(center)[
          #text(12pt, weight: "bold")[HÀ NỘI -- #year]
        ]
      ]
    ]
  ]
}

// ===== BÌA 2: bìa phụ (thông tin chi tiết) =====
#let uet-cover2(
  title: "",
  document-type: "BÀI TẬP LỚN",
  major: "Công nghệ kỹ thuật điều khiển và tự động hoá",
  supervisor: ".......................................",
  year: 2026,
  members: (),
) = {
  page(margin: 0pt, header: none, footer: none, numbering: none)[
    #block(width: 210mm, height: 297mm)[
      #uet-borders()
      #uet-inner[
        #uet-school
        #v(1.4cm)
        #align(center)[
          #text(16pt, weight: "bold")[#upper(document-type)]
        ]
        #v(0.6cm)
        #align(center)[
          #text(16pt, weight: "bold")[#upper(title)]
        ]
        #v(1.0cm)
        #align(center)[
          #text(12pt)[Ngành: #major]
        ]
        #v(1fr)
        #align(center)[
          #text(12pt, weight: "bold")[Nhóm sinh viên thực hiện]
          #v(4pt)
          #uet-members(members)
        ]
        #v(1fr)
        #align(center)[
          #text(12pt, weight: "bold")[Giảng viên hướng dẫn]
          #v(4pt)
          #text(12pt)[#supervisor]
        ]
        #v(1fr)
        #align(center)[
          #text(12pt, weight: "bold")[HÀ NỘI -- #year]
        ]
      ]
    ]
  ]
}