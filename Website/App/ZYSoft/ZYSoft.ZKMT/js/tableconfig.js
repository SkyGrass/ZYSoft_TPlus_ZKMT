const tableconf_qgd = [
{
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
    title: "序号",
    field: "FNo",
    hozAlign: "center",
    width: 40,
    headerSort: false
},
{
    title: "项目编码",
    field: "FProjectCode",
    hozAlign: "center",
    width: 120,
    headerSort: false
},
{
    title: "项目名称",
    field: "FProjectName",
    hozAlign: "center",
    width: 180,
    headerSort: false
},
{
    title: "存货编码",
    field: "FInvCode",
    hozAlign: "center",
    width: 150,
    headerSort: false
},
{
    title: "存货名称",
    field: "FInvName",
    hozAlign: "center",
    headerSort: false,
    width: 150,
},
{
    title: "单位",
    field: "FUnitName",
    hozAlign: "center",
    headerSort: false,
    width: 60
},
{
    title: "数量",
    field: "FPlanQuantity",
    hozAlign: "right",
    width: 100,
    headerSort: false,
    editor: false,
},
{
    title: "需求日期",
    field: "FRequireDate",
    hozAlign: "center",
    width: 120,
    headerSort: false,
    formatter: "datetime",
    formatterParams: {
        inputFormat: "YYYY-MM-DD",
        outputFormat: "YYYY-MM-DD",
        invalidPlaceholder: "",
    }
},
{
    title: "库存数量",
    field: "FCurQuantity",
    hozAlign: "right",
    width: 100,
    headerSort: false,
    editor: false,
},
{
    title: "请购数量",
    field: "FQuantity",
    hozAlign: "center",
    width: 100,
    headerSort: false, hozAlign: "right", editor: "input",
    editor: true, validator: ["min:0", "numeric"]
},
{
    title: "网址链接",
    field: "FWebsiteLink",
    hozAlign: "center",
    headerSort: false,
    width: 250
},
{
    title: "备注",
    field: "FRemark",
    hozAlign: "center",
    headerSort: false,
    width: 250,
},
{
    title: "检查结果",
    field: "FIsValid",
    hozAlign: "center",
    formatter: "tickCross",
    width: 80,
    headerSort: false,
    editor: false,
},
{
    title: "原因",
    field: "FErrorMsg",
    hozAlign: "center",
    headerSort: false,
    width: 300,
    formatter: function (cell, formatterParams) {
        var value = cell.getValue();
        console.log(value)
        return value.indexOf('通过') > -1 ? "<span style='color:green; font-weight:bold;'>" + value + "</span>" :
            "<span style='color:red; font-weight:bold;'>" + value + "</span>";
    }
}
]
