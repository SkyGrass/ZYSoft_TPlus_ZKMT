const tableconf_cgd = [
            {
                title: "勾选",
                formatter: "rowSelection",
                titleFormatter: "rowSelection",
                hozAlign: "center",
                headerSort: false,
                frozen: true
            },
            {
                title: "采购订单",
                field: "code",
                hozAlign: "center",
                width: 150,
                sorter: "string",
            },
            {
                title: "订单日期",
                field: "voucherdate",
                hozAlign: "center",
                width: 120,
                sorter: "date", sorterParams: { format: "YYYY-MM-DD" },
                formatter: "datetime",
                formatterParams: {
                    inputFormat: "YYYY-MM-DD",
                    outputFormat: "YYYY-MM-DD",
                    invalidPlaceholder: "",
                }
            },
            {
                title: "供应商",
                field: "VendorName",
                hozAlign: "center",
                width: 200,
                sorter: "string"
            },
            {
                title: "存货编码",
                field: "cInvCode",
                hozAlign: "center",
                width: 150,
                sorter: "string"
            },
            {
                title: "存货名称",
                field: "cInvName",
                hozAlign: "center",
                headerSort: false,
                width: 250,
            },
            {
                title: "存货型号",
                field: "cInvStd",
                hozAlign: "center",
                headerSort: false,
                width: 150,
            },
            {
                title: "数量",
                field: "iQuantity",
                hozAlign: "right",
                width: 120,
                bottomCalc: "sum", bottomCalcParams: { precision: 3 },
                headerSortTristate: true,
                editor: false,
            },
            {
                title: "税率",
                field: "iTaxRate",
                hozAlign: "right",
                width: 120,
                headerSortTristate: true,
                hozAlign: "right",
                editor: false,
            }, {
                title: "含税单价",
                field: "iTaxPrice",
                hozAlign: "right",
                width: 120,
                headerSortTristate: true,
                hozAlign: "right", editor: "input",
                editor: true, validator: ["min:0", "numeric"]
            },
            {
                title: "含税金额",
                field: "iTaxAmount",
                hozAlign: "right",
                width: 120,
                headerSortTristate: true,
                bottomCalc: "sum", bottomCalcParams: { precision: 3 },
                editor: false,
            }
]