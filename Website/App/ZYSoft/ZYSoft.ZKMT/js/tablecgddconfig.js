const tableconf_cgdd = [{
    title: "勾选",
    formatter: "rowSelection",
    titleFormatter: "rowSelection",
    hozAlign: "center",
    headerSort: false,
    frozen: true,
    cellClick: function (e, cell) {
        cell.getRow().toggleSelect();
    }
},
{
    title: "序",
    field: "FIndex",
    hozAlign: "center",
    width: 60,
    frozen: true,
    headerSort: true
},
{
    title: "采购状态",
    field: "pubuserdefnvc7",
    hozAlign: "center",
    width: 100,
    frozen: true,
    headerSort: true,
    formatter: function (cell, formatterParams) {
        var value = cell.getValue();
        if (value == "否") {
            return "<span style='color:green'>采购</span>";
        } else {
            return "<span style='color:red;font-weight:bold;'>已中止</span>";
        }
    }
},
{
    title: "供应商",
    field: "FVenderName",
    hozAlign: "center",
    width: 150,
    frozen: true,
    headerSort: true
},
{
    title: "供应商",
    field: "FVenderCode",
    hozAlign: "center",
    visible: false,
    frozen: true,
    headerSort: true
},
{
    title: "项目编码",
    field: "FProjectCode",
    hozAlign: "center",
    width: 100,
    frozen: true,
    headerSort: true
},
{
    title: "项目名称",
    field: "FProjectName",
    hozAlign: "center",
    width: 150,
    frozen: true,
    headerSort: true
},
{
    title: "请购单号",
    field: "FBillNo",
    hozAlign: "center",
    width: 150,
    frozen: true,
    headerSort: true
},
{
    title: "请购日期",
    field: "FDate",
    hozAlign: "center",
    width: 120,
    frozen: true,
    sorter: "date",
    sorterParams: {
        format: "YYYY-MM-DD"
    },
    formatter: "datetime",
    formatterParams: {
        inputFormat: "YYYY-MM-DD",
        outputFormat: "YYYY-MM-DD",
        invalidPlaceholder: "",
    }
},
{
    title: "请购人",
    field: "FRequisitionPerson",
    hozAlign: "center",
    width: 100,
    frozen: true,
    headerSort: true
},
{
    title: "存货编码",
    field: "FInvNumber",
    hozAlign: "center",
    width: 150,
    frozen: true,
    headerSort: true,
},
{
    title: "存货名称",
    field: "FInvName",
    hozAlign: "center",
    frozen: true,
    headerSort: true,
    width: 150,
},
{
    title: "存货规格",
    field: "FInvStd",
    hozAlign: "center",
    frozen: true,
    headerSort: false,
    width: 150,
},
{
    title: "计量单位",
    field: "FUnit",
    hozAlign: "center",
    frozen: true,
    headerSort: false,
    width: 80
},
{
    title: "品牌",
    field: "FBrand",
    hozAlign: "center",
    frozen: true,
    headerSort: true,
    width: 80
},
{
    title: "请购数量",
    field: "FQty",
    hozAlign: "right",
    width: 100,
    headerSortTristate: true,
    editor: false,
},
{
    title: "可用量",
    field: "FStockQty",
    hozAlign: "right",
    width: 100,
    headerSortTristate: true,
    editor: false,
    formatter: "color",
    formatter: function (cell, formatterParams) {
        var value = cell.getValue();
        return "<span style='color:#FF8C00; font-weight:bold;'>" + value + "</span>";
    }
},
{
    title: "安全库存",
    field: "FSafeQty",
    hozAlign: "right",
    width: 100,
    headerSortTristate: true,
    editor: false,
},
{
    title: "未采购量",
    field: "FUnPOQty",
    hozAlign: "center",
    width: 100,
    headerSortTristate: true,
    hozAlign: "right",
    editor: "input",
    editor: false,
},
{
    title: "总请购量",
    field: "FTotalPurReqQty",
    hozAlign: "center",
    width: 100,
    headerSortTristate: true,
    hozAlign: "right",
    editor: "input",
    editor: false,
},
{
    title: "总出库量",
    field: "FTotalOutQty",
    hozAlign: "center",
    width: 100,
    headerSortTristate: true,
    hozAlign: "right",
    editor: "input",
    editor: false,
},
{
    title: "建议采购量",
    field: "FAdviseQty",
    hozAlign: "center",
    width: 100,
    headerSortTristate: true,
    hozAlign: "right",
    editor: false,
}, {
    title: "本次采购量",
    field: "FQuantity",
    hozAlign: "right",
    width: 100,
    headerSortTristate: true,
    hozAlign: "right", editor: "input",
    editor: true, validator: ["min:0", "numeric"]
}
]
