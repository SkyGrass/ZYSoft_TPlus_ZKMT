var vm = new Vue({
    el: "#app",
    data: function () {
        return {
            project: [],
            persons: [],
            dept: [],
            user: [{ code: loginUserCode, name: loginName }],
            loading: false,
            fileName: "",
            grid: {},
            tableData: [],
            idProject: -1,
            codeProject: "",
            maxlength: 0,
            keyword: "",
            poflag: "0",
            keyword_partner: "",
            keyword_project: "",
            pomark: [{ code: "-1", name: "全部" }, { code: "0", name: "采购" }, { code: "1", name: "取消采购" }],
            form: {
                FUserCode: loginUserCode,
                FUserName: loginName,
                FDate: moment().format('YYYY-MM-DD'),
                FPersonCode: "",
                FDeptCode: "",
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
            currentRow: {},
            actionColumn: {
                title: "操作",
                field: "pubuserdefnvc7",
                hozAlign: "center",
                headerSort: false,
                width: 100,
                formatter: function (cell, formatterParams) {
                    var value = cell.getValue();
                    return '<input type="button" style="' + vm.btnTitleColor(value) + '"  value="' + vm.btnTitle(value) + '">'
                }
            }
        };
    },
    methods: {
        btnTitle(value) {
            return value == '是' ? '恢复采购' : '取消采购'
        },
        btnTitleColor(value) {
            return value == '是' ? 'color: #fff;border-color:#3a8ee6;background-color: #3a8ee6;' : 'color: #fff;border-color:#e6a23c;background-color: #e6a23c;'
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
            var item = this.project.filter(function (f) {
                return f.code == e
            })
            this.idProject = item[0].id;
        },
        queryRecord() {
            this.getList()
        },
        getList() {
            var that = this;
            if (this.idProject < 0) {
                return that.$message({
                    message: '请先选择项目!',
                    type: 'warning'
                });
            }
            $.ajax({
                type: "POST",
                url: "zkmtcgddhandler.ashx",
                async: true,
                data: { SelectApi: "getprojectdetail", idProject: this.idProject, poflag: this.poflag, keyword: this.keyword, keyword_project: this.keyword_project },
                dataType: "json",
                success: function (result) {
                    if (result.status == "success") {
                        that.tableData = result.data.map(function (row) {
                            row.FVenderCode = "";
                            row.FVenderName = "";
                            row.FQuantity = row.FUnPOQty;
                            return row;
                        });
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
            var result = false;
            if (this.form.FDate == null) {
                result = true;
                this.$message({
                    message: '尚未指定日期,请核实!',
                    type: 'warning'
                });
            }
            var array = this.grid.getSelectedData();
            if (array.some(function (row) { return row.FVenderCode == "" })) {
                result = true;
                this.$message({
                    message: '发现了未设置供应商的行,请核实!',
                    type: 'warning'
                });
            } else {
                if (array.some(function (f) { return f.FQuantity <= 0 })) {
                    result = true;
                    this.$message({
                        message: '本次采购量不合法,请核实!',
                        type: 'warning'
                    });
                }
            }

            return result;
        },
        saveTable() {
            var that = this;
            if (!this.beforeSave()) {
                var temp = this.grid.getSelectedData().filter(function (row) {
                    return row.FVenderCode != "" && row.FQuantity > 0
                }).map(function (m) {
                    return {
                        FVenderCode: m.FVenderCode,
                        FSourceBillID: m.FID,
                        FSourceBillNo: m.FBillNo,
                        FSourceBillEntryID: m.FEntryID,
                        FSourceBillEntryRowNo: m.FIndex,
                        FInvCode: m.FInvNumber,
                        FProjectCode: that.codeProject,
                        FQuantity: m.FQuantity
                    }
                });

                if (temp.length > 0) {

                    this.$confirm('此操作将提交单据,共有' + temp.length + '行设置了供应商, 是否继续?', '提示', {
                        confirmButtonText: '确定',
                        cancelButtonText: '取消',
                        type: 'warning'
                    }).then(function () {
                        that.loading = true;
                        $.ajax({
                            type: "POST",
                            url: "zkmtcgddhandler.ashx",
                            async: true,
                            data: { SelectApi: "savepo", formdata: JSON.stringify(Object.assign({}, this.form, { Entry: temp })) },
                            dataType: "json",
                            success: function (result) {
                                that.loading = false;
                                if (result.status == "success") {
                                    that.tableData = [];
                                    that.idProject = -1;
                                    that.codeProject = ""
                                    that.dialogTableVisible = false;
                                    that.currentRow = {}
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
                    }).catch(function () { })
                } else {
                    this.$message({
                        message: '尚未查询到已经设置了供应商的行记录,请核实!',
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
        unPOMarkSingle(data) {
            var that = this;
            var val = data.pubuserdefnvc7 || '否';
            var id = data.FEntryID;
            vm.$confirm('确定要' + vm.btnTitle(val) + '此行的存货吗?', '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(function () {
                $.ajax({
                    type: "POST",
                    url: "zkmtcgddhandler.ashx",
                    async: true,
                    data: {
                        SelectApi: "unpomark",
                        ids: id,
                        flag: val == '是' ? '0' : '1'

                    },
                    dataType: "json",
                    success: function (result) {

                        that.loading = false;
                        if (result.status == "success") {
                            var index = that.tableData.findIndex(function (row) {
                                return row.FEntryID == id
                            });
                            that.tableData[index]["pubuserdefnvc7"] = val == '是' ? '否' : '是';
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
                        return that.$message({
                            message: '更新单据失败,请检查!',
                            type: 'warning'
                        });
                    }
                })

            }).catch(function () {

            })

        },
        updateMark() {
            var selectRow = vm.grid.getSelectedData();
            if (selectRow.length <= 0) {
                return vm.$message({
                    message: '没有发现选中行!',
                    type: 'warning'
                });
            } else {
                this.getPartner();
                this.dialogTableVisible = !this.dialogTableVisible;
            }
        },
        confirmMark() {
            var that = this;
            if (Object.keys(this.currentRow || {}).length > 0) {
                this.$confirm('此操作将选中行的供应商设置为【' + this.currentRow.name + '】, 是否继续?', '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    type: 'warning'
                }).then(function () {
                    var selectedRow = that.grid.getSelectedData();
                    if (selectedRow && selectedRow.length > 0) {
                        selectedRow.forEach(function (sr) {
                            var index = that.tableData.findIndex(function (row) {
                                return row.FEntryID == sr.FEntryID
                            })
                            if (index > -1) {
                                var row = that.grid.getRowFromPosition(index, true);
                                //row.getCell('FVenderName').setValue(that.currentRow.name);
                                //row.getCell('FVenderCode').setValue(that.currentRow.code);
                                that.tableData[index]["FVenderName"] = that.currentRow.name;
                                that.tableData[index]["FVenderCode"] = that.currentRow.code
                            }
                        })
                    }
                    that.dialogTableVisible = !that.dialogTableVisible;
                    that.currentRow = {};
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
            handler: function (newData, oldData) {
                this.grid.replaceData(newData);
            },
            deep: true
        }
    },
    mounted() {
        var that = this;
        this.handleGetProject();
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
            columns: tableconf_cgdd.concat(that.actionColumn),
            rowContextMenu: this.rowMenu,
            cellClick: function (e, cell) {
                var columnName = cell.getField();
                if (columnName == "pubuserdefnvc7") {
                    vm.unPOMarkSingle(cell.getData())
                }
            }
        })
    }
});