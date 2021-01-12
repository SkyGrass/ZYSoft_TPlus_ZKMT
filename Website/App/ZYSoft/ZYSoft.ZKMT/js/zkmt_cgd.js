var vm = new Vue({
    el: "#app",
    data: function () {
        return {
            pickerOptions: {
                shortcuts: [{
                    text: '最近一周',
                    onClick(picker) {
                        const end = new Date();
                        const start = new Date();
                        start.setTime(start.getTime() - 3600 * 1000 * 24 * 7);
                        picker.$emit('pick', [start, end]);
                    }
                }, {
                    text: '最近一个月',
                    onClick(picker) {
                        const end = new Date();
                        const start = new Date();
                        start.setTime(start.getTime() - 3600 * 1000 * 24 * 30);
                        picker.$emit('pick', [start, end]);
                    }
                }, {
                    text: '最近三个月',
                    onClick(picker) {
                        const end = new Date();
                        const start = new Date();
                        start.setTime(start.getTime() - 3600 * 1000 * 24 * 90);
                        picker.$emit('pick', [start, end]);
                    }
                }]
            },
            loading: false,
            grid: {},
            form: {
                ordercode: '',
                voucherdate: [moment().startOf('month').format("YYYY-MM-DD"), moment().format("YYYY-MM-DD")],
                vendor: '',
                cinv: ''
            }
        }
    },
    methods: {
        queryRecord() {
            this.getList()
        },
        getList() {
            var that = this;
            if (this.form.vendor == '') {
                return that.$message({
                    message: '请先输入供应商编号或者名称!',
                    type: 'warning'
                });
            }
            $.ajax({
                type: "POST",
                url: "zkmthandler.ashx",
                async: true,
                data: Object.assign({}, this.form,
                    { SelectApi: "getcgorder" },
                    {
                        startdate: this.form.voucherdate != null ? this.form.voucherdate[0] : "",
                        enddate: this.form.voucherdate != null ? this.form.voucherdate[1] : ""
                    }),
                dataType: "json",
                success: function (result) {
                    that.grid.clearData();
                    if (result.status == "success") {
                        that.grid.replaceData(result.data);
                    } else {
                        return that.$message({
                            message: '未能查询到采购订单信息!',
                            type: 'warning'
                        });
                    }
                    that.maxlength = result.data.length;
                },
                error: function () {
                    that.grid.clearData();
                }
            });
        },
        beforeSave() {
            var that = this;
            var result = false;
            var array = this.grid.getSelectedData();
            if (array.some(function (f) { return f.iTaxPrice <= 0 })) {
                result = true;
                this.$message({
                    message: '含税单价不合法,请核实!',
                    type: 'warning'
                });
            }
            return result;
        },
        saveTable() {
            var that = this;
            if (!this.beforeSave()) {

                var temp = this.grid.getSelectedData().map(function (m) {
                    return {
                        iTaxPrice: m.iTaxPrice,
                        iEntryId: m.iEntryID,
                        id: m.id
                    }
                });
                if (temp.length > 0) {
                    that.loading = true;
                    that.$confirm('此操作将更新选中行的含税单价, 是否继续?', '提示', {
                        confirmButtonText: '确定',
                        cancelButtonText: '取消',
                        type: 'warning'
                    }).then(function () {
                        $.ajax({
                            type: "POST",
                            url: "zkmthandler.ashx",
                            async: true,
                            data: { SelectApi: "savecgd", formdata: JSON.stringify(temp) },
                            dataType: "json",
                            success: function (result) {
                                that.loading = false;
                                if (result.status == "success") {
                                    that.queryRecord();
                                    return that.$message({
                                        message: result.msg,
                                        type: 'success'
                                    });
                                } else {
                                    return that.$message({
                                        message: result.msg,
                                        type: 'warning'
                                    });
                                }
                            },
                            error: function () {
                                that.loading = false;
                                that.$message({
                                    message: '更新单价失败,请检查!',
                                    type: 'warning'
                                });
                            }
                        })
                    }).catch(function () { that.loading = false; });
                } else {
                    this.$message({
                        message: '尚未勾选行记录,请核实!',
                        type: 'warning'
                    });
                }
            }
        },
        accMul(num1, num2) {
            var m = 0,
              s1 = num1.toString(),
              s2 = num2.toString();
            try {
                m += s1.split(".")[1].length;
            } catch (e) { }
            try {
                m += s2.split(".")[1].length;
            } catch (e) { }
            return (
              (Number(s1.replace(".", "")) * Number(s2.replace(".", ""))) /
              Math.pow(10, m)
            );
        }
    },
    watch: {
        tableData1: {
            handler: function (newData) {
                this.grid.replaceData(newData);
            },
            deep: true
        }
    },
    mounted() {
        var that = this;

        this.maxHeight = ($(window).height() - $("#header").height() - 80)
        window.onresize = function () {
            that.maxHeight = ($(window).height() - $("#header").height() - 80)
        }
        this.grid = new Tabulator("#grid", {
            height: that.maxHeight,
            columnHeaderVertAlign: "bottom",
            //data: this.tableData, //set initial table data
            columns: tableconf_cgd,
            selectable: 9999, //make rows selectable
            selectableRollingSelection: false,
            cellEdited: function (cell) {
                if (cell.getField() == 'iTaxPrice') {
                    var val = cell.getValue();
                    const qty = cell.getRow().getCell('iQuantity').getValue()
                    cell.getRow().getCell('iTaxAmount').setValue(that.accMul(val, qty))

                }
            },
        })
    }
});