var vm = new Vue({
    el: "#app",
    data: function () {
        return {
            persons: [],
            dept: [],
            user: [{ code: loginUserCode, name: loginName }],
            materialVisible: false,
            markerVisible: false,
            loading: false,
            fileName: "",
            grid: {},
            form: {
                FUserCode: loginUserCode,
                FUserName: loginName,
                FDate: moment().format('YYYY-MM-DD'),
                FPersonCode: "",
                FDeptCode: "",
                FMemo: ""
            }
        };
    },
    methods: {
        importExcle() {
            alert(1)
        },
        uploadSuccess(response, file, fileList) {
            if (response.state == "success") {
                this.grid.replaceData(response.data);
                this.fileName = response.fileName;
            }
            this.loading = false;
            return this.$message({
                message: response.data.length > 0 ? '导入完成!' : '未能导入数据!',
                type: response.data.length > 0 ? 'success' : 'warning'
            });
        },
        uploadBefore(file) {
            this.loading = true;
        },
        clearTable() {
            this.grid.clearData();
        },
        checkTable() {
            const that = this;
            if (this.grid.getData().length <= 0) return;
            this.loading = true;
            $.ajax({
                type: "POST",
                url: "uploadhandler.ashx",
                async: true,
                data: { SelectApi: "check", dataSource: JSON.stringify(that.grid.getData()) },
                dataType: "json",
                success: function (response) {
                    that.loading = false;
                    if (response.state == "success") {
                        that.grid.replaceData(response.data);
                    }
                    that.loading = false;
                    return that.$message({
                        message: response.data.length > 0 ? '检查完成!' : '未能检查数据!',
                        type: response.data.length > 0 ? 'success' : 'warning'
                    });
                },
                error: function () {
                    that.loading = false;
                    return that.$message({
                        message: '未能正确检查数据!',
                        type: 'warning'
                    });
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
        beforeSave() {
            var that = this;
            var result = false;
            const array = this.grid.getSelectedData();
            if (this.form.FPersonCode == "") {
                result = true;
                this.$message({
                    message: '尚未选择选购人,请核实!',
                    type: 'warning'
                });
            }
            if (this.form.FDeptCode == "") {
                result = true;
                this.$message({
                    message: '尚未选择部门,请核实!',
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
            if (this.form.FUserCode == "") {
                result = true;
                this.$message({
                    message: '尚未选择制单人,请核实!',
                    type: 'warning'
                });
            }
            if (array.some(function (f) { return f.FIsValid == false })) {
                result = true;
                this.$message({
                    message: '请购单检查未通过,请核实!',
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
                        FInvCode: m.FInvCode,
                        FProjectCode: m.FProjectCode,
                        FQuantity: m.FQuantity,
                        FRequireDate: m.FRequireDate,
                        FRemark: m.FRemark,
                        FWebsiteLink: m.FWebsiteLink
                    }
                });

                if (temp.length > 0) {
                    that.loading = true;
                    $.ajax({
                        type: "POST",
                        url: "zkmthandler.ashx",
                        async: true,
                        data: { SelectApi: "saveqgd", formdata: JSON.stringify(Object.assign({}, this.form, { Entry: temp })) },
                        dataType: "json",
                        success: function (result) {
                            that.loading = false;
                            if (result.status == "success") {
                                that.grid.clearData();
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
        this.handleGetPerson();
        this.handleGetDept();

        this.maxHeight = ($(window).height() - $("#header").height())
        window.onresize = function () {
            that.maxHeight = ($(window).height() - $("#header").height())
        }
        this.grid = new Tabulator("#grid", {
            height: this.maxHeight,
            columnHeaderVertAlign: "bottom",
            selectable: true, //make rows selectable
            //data: this.tableData, //set initial table data
            columns: tableconf_qgd
        })
    }
});