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
    headerSort: true
},
{
    title: "供应商",
    field: "FVenderName",
    hozAlign: "center",
    width: 150,
    headerSort: true
},
{
    title: "供应商",
    field: "FVenderCode",
    hozAlign: "center",
    visible: false,
    headerSort: true
},
{
    title: "请购单号",
    field: "FBillNo",
    hozAlign: "center",
    width: 150,
    headerSort: true
},
{
    title: "请购日期",
    field: "FDate",
    hozAlign: "center",
    width: 120,
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
    title: "存货编码",
    field: "FInvNumber",
    hozAlign: "center",
    width: 150,
    sorter: "string"
},
{
    title: "存货名称",
    field: "FInvName",
    hozAlign: "center",
    headerSort: false,
    width: 150,
},
{
    title: "存货规格",
    field: "FInvStd",
    hozAlign: "center",
    headerSort: false,
    width: 150,
},
{
    title: "计量单位",
    field: "FUnit",
    hozAlign: "center",
    headerSort: false,
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
