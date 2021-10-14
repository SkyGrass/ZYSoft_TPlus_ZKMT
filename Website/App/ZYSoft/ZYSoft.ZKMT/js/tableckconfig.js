const tableconf_qgd = [{
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
        title: "项目结存",
        field: "FProjectStockQty",
        hozAlign: "right",
        width: 120,
        headerSortTristate: true,
        editor: false,
    },
	{
	    title: "请购数量",
	    field: "FQty",
	    hozAlign: "right",
	    width: 120,
	    headerSortTristate: true,
	    editor: false,
	},
	{
	    title: "已出库数量",
	    field: "FOutQty",
	    hozAlign: "right",
	    width: 120,
	    headerSortTristate: true,
	    editor: false,
	},
	{
	    title: "库存数量",
	    field: "FStockQty",
	    hozAlign: "right",
	    width: 120,
	    headerSortTristate: true,
	    editor: false,
	},
	{
	    title: "出库数量",
	    field: "FUnOutQty",
	    hozAlign: "center",
	    width: 120,
	    headerSortTristate: true,
	    hozAlign: "right",
	    editor: "input",
	    editor: true,
	    validator: {
	        type: function (cell, value, parameters) {
	            var FUnOutQty = value;
	            var FQty = cell.getData()['FQty'];
	            var FOutQty = cell.getData()['FOutQty'];
	            return (Number(FQty) - Number(FOutQty) >= FUnOutQty)
	        }
	    }
	},
	{
		title: "备注",
		field: "FRemark",
		hozAlign: "center",
		headerSort: false,
		width: 250,
	}
]