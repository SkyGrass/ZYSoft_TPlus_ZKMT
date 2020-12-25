var vm = new Vue({
    el: "#app",
    data: function () {
        return {
            project: [],
            stock: [],
            persons: [],
            dept: [],
            user: [{ code: loginUserCode, name: loginName }],
            materialVisible: false,
            markerVisible: false,
            loading: false,
            fileName: "",
            grid: {},
            tableData: [{ FIndex: 1, FInvNumber: '20202' }, { FIndex: 2, FInvNumber: '20203' }, { FIndex: 3, FInvNumber: '20202' }],
            idProject: -1,
            idStock: -1,
            noZero: false,
            maxlength: 0,
            keyword: "",
            keyword_partner: "",
            keyword_project: "",
            form: {
                FProjectCode: "",
                FUserCode: loginUserCode,
                FUserName: loginName,
                FDate: moment().format('YYYY-MM-DD'),
                FPersonCode: "",
                FDeptCode: "",
                FWhCode: "",
                FMemo: ""
            },
            dialogTableVisible: false,
            rowMenu: [
                   {
                       label: "<i class='fas fa-user'></i>勾选全部相同存货编号行",
                       action: function (e, row) {
                           var code = row.getCell("FInvNumber").getValue();
                           vm.updateRowSelection(code, 1)
                       }
                   },
                    {
                        label: "<i class='fas fa-user'></i>反选全部相同存货编号行",
                        action: function (e, row) {
                            var code = row.getCell("FInvNumber").getValue();
                            vm.updateRowSelection(code, 0)
                        }
                    }
            ],
            partnerList: [],
            currentRow: {}
        };
    },
    methods: {
        clearTable() {
            this.tableData = [];
        },
        handleGetProject() {
            var that = this;
            $.ajax({
                type: "POST",
                url: "zkmthandler.ashx",
                async: true,
                data: { SelectApi: "getproject" },
                dataType: "json",
                success: function (result) {
                    if (result.status == "success") {
                        that.project = result.data;
                        if (that.project.length > 0) {
                            //that.form.FProjectCode = that.project[0]["code"];
                        }
                    } else {
                        return that.$message({
                            message: '未能查询到项目信息!',
                            type: 'warning'
                        });
                    }
                },
                error: function () {
                }
            });
        },
        handleGetStock() {
            var that = this;
            $.ajax({
                type: "POST",
                url: "zkmthandler.ashx",
                async: true,
                data: { SelectApi: "getstock" },
                dataType: "json",
                success: function (result) {
                    if (result.status == "success") {
                        that.stock = result.data;
                        if (that.stock.length > 0) {
                            //that.form.FWhCode = that.stock[0]["code"];
                        }
                    } else {
                        return that.$message({
                            message: '未能查询到仓库信息!',
                            type: 'warning'
                        });
                    }
                },
                error: function () {
                }
            });
        },
        handleGetPerson() {
            var that = this;
            $.ajax({
                type: "POST",
                url: "zkmthandler.ashx",
                async: true,
                data: { SelectApi: "getperson" },
                dataType: "json",
                success: function (result) {
                    if (result.status == "success") {
                        that.persons = result.data;
                        if (that.persons.length > 0) {
                            that.form.FPersonCode = that.persons[0]["code"];
                        }
                    } else {
                        return that.$message({
                            message: '未能查询到请购人信息!',
                            type: 'warning'
                        });
                    }
                },
                error: function () {
                }
            });
        },
        handleGetDept() {
            var that = this;
            $.ajax({
                type: "POST",
                url: "zkmthandler.ashx",
                async: true,
                data: { SelectApi: "getdept" },
                dataType: "json",
                success: function (result) {
                    if (result.status == "success") {
                        that.dept = result.data;
                        if (that.dept.length > 0) {
                            that.form.FDeptCode = that.dept[0]["code"];
                        }
                    } else {
                        return that.$message({
                            message: '未能查询到部门信息!',
                            type: 'warning'
                        });
                    }
                },
                error: function () {
                }
            });
        },
        handleChangProject(e) {
            var that = this;
            var item = this.project.filter(function (f) {
                return f.code == e
            })
            this.idProject = item[0].id;
            //this.getList();
        },
        handleChangStock(e) {
            var that = this;
            var item = this.stock.filter(function (f) {
                return f.code == e
            })
            this.idStock = item[0].id;
            //this.getList();
        },
        queryRecord() {
            this.getList()
        },
        getList() {
            var that = this;
            if (this.idStock < 0 || this.idProject < 0) {
                return that.$message({
                    message: '请先选择项目和仓库!',
                    type: 'warning'
                });
            }
            $.ajax({
                type: "POST",
                url: "zkmthandler.ashx",
                async: true,
                data: { SelectApi: "getprojectdetail", idProject: this.idProject, idStock: this.idStock, noZero: this.noZero, keyword: this.keyword, keyword_project: this.keyword_project },
                dataType: "json",
                success: function (result) {
                    if (result.status == "success") {
                        that.tableData = result.data;
                    } else {
                        that.tableData = [];
                        return that.$message({
                            message: '未能查询到项目信息!',
                            type: 'warning'
                        });
                    }
                    that.maxlength = result.data.length;
                },
                error: function () {
                    that.tableData = [];
                }
            });
        },
        beforeSave() {
            var that = this;
            var result = false;
            var array = this.grid.getSelectedData();
            if (this.form.FProjectCode == "") {
                result = true;
                this.$message({
                    message: '尚未选择项目,请核实!',
                    type: 'warning'
                });
            }
            if (this.form.FWhCode == "") {
                result = true;
                this.$message({
                    message: '尚未选择仓库,请核实!',
                    type: 'warning'
                });
            }
            if (this.form.FDate == null) {
                result = true;
                this.$message({
                    message: '尚未指定日期,请核实!',
                    type: 'warning'
                });
            }

            if (array.some(function (f) { return f.FUnOutQty > f.FStockQty })) {
                result = true;
                this.$message({
                    message: '发现超库存出库,请核实!',
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
                        FInvCode: m.FInvNumber,
                        FProjectCode: m.FProjectCode,
                        FQuantity: m.FUnOutQty,
                        FPurRequstBillNo: m.FBillNo,
                        FPurRequstBillID: m.FID,
                        FPurRequstBillEntryID: m.FEntryID
                    }
                });

                if (temp.length > 0) {

                    that.loading = true;
                    $.ajax({
                        type: "POST",
                        url: "zkmthandler.ashx",
                        async: true,
                        data: { SelectApi: "saveck", formdata: JSON.stringify(Object.assign({}, this.form, { Entry: temp })) },
                        dataType: "json",
                        success: function (result) {

                            that.loading = false;
                            if (result.status == "success") {
                                that.tableData = [];
                                that.form.FProjectCode = "";
                                that.form.FWhCode = "";
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
                                message: '保存单据失败,请检查!',
                                type: 'warning'
                            });
                        }
                    })
                } else {
                    this.$message({
                        message: '尚未勾选行记录,请核实!',
                        type: 'warning'
                    });
                }
            }
        },
        updateRowSelection(code, flag) {
            var selectRow = vm.grid.getSelectedData();
            if (selectRow.length > 0 && flag == 1) {
                return vm.$message({
                    message: '此功能仅在表格内没有行被选中的情况下有效!',
                    type: 'warning'
                });
            } else {
                this.tableData.forEach(function (item, index) {
                    if (item.FInvNumber == code) {
                        var row = vm.grid.getRowFromPosition(index, true);
                        if (row) {
                            if (flag)
                                row.select()
                            else
                                row.deselect();
                        }
                    }
                })
            }
        },
        unPOMark() {
            var selectRow = vm.grid.getSelectedData();
            if (selectRow.length <= 0) {
                return vm.$message({
                    message: '没有发现选中行!',
                    type: 'warning'
                });
            } else {
                vm.$confirm('此操作将选中行标记为不采购, 是否继续?', '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    type: 'warning'
                }).then(function () {

                }).catch(function () { })
            }
        },
        updateMark() {
            var selectRow = vm.grid.getSelectedData();
            if (selectRow.length <= 0) {
                return vm.$message({
                    message: '没有发现选中行!',
                    type: 'warning'
                });
            } else {
                this.dialogTableVisible = !this.dialogTableVisible;

            }
        },
        confirmMark() {
            if (Object.keys(this.currentRow || {}).length > 0) {
                this.$confirm('此操作将选中行的供应商更新为【' + this.currentRow.name + '】, 是否继续?', '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    type: 'warning'
                }).then(function () {
                    vm.$message({
                        message: '更新成功!',
                        type: 'success'
                    });
                    vm.dialogTableVisible = false;
                    vm.currentRow = {}
                }).catch(function () { })
            } else {
                return this.$message({
                    message: '没有发现选中供应商!',
                    type: 'warning'
                });
            }
        },
        handleCurrentChange(val) {
            this.currentRow = val || {}
        },
        getPartner() {
            var that = this;
            $.ajax({
                type: "POST",
                url: "zkmtcgddhandler.ashx",
                async: true,
                data: { SelectApi: "getpartner", keyword: this.keyword_partner },
                dataType: "json",
                success: function (result) {
                    if (result.status == "success") {
                        that.partnerList = result.data;
                        if (result.data.length == 1) {
                            that.currentRow = result.data[0]
                            that.$refs.singleTable.setCurrentRow(result.data[0]);
                        } else {
                            that.currentRow = {};
                        }
                    } else {
                        return that.$message({
                            message: '未能查询到项目信息!',
                            type: 'warning'
                        });
                    }
                },
                error: function () {
                }
            });
        },
    },
    watch: {
        tableData: {
            handler: function (newData) {
                this.grid.replaceData(newData);
            },
            deep: true
        }
    },
    mounted() {
        var that = this;
        this.handleGetProject();
        this.handleGetStock();
        this.handleGetPerson();
        this.handleGetDept();

        this.maxHeight = ($(window).height() - $("#header").height() - 80)
        window.onresize = function () {
            that.maxHeight = ($(window).height() - $("#header").height() - 80)
        }
        this.grid = new Tabulator("#grid", {
            height: that.maxHeight,
            columnHeaderVertAlign: "bottom",
            selectable: 9999, //make rows selectable
            selectableRollingSelection: false,
            data: this.tableData, //set initial table data
            columns: tableconf_qgd,
            rowContextMenu: this.rowMenu,
        })
    }
});