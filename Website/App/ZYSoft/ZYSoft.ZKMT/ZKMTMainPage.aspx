<%@ Page Language="C#" AutoEventWireup="true" %>

<%-- CodeFile="ZKMTMainPage.aspx.cs" Inherits="App_ZYSoft_ZYSoft_ZKMT_ZKMTMainPage" --%>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <title>请购单</title>
    <!-- 引入样式 -->
    <link rel="stylesheet" href="./css/element-ui-index.css" />
    <link rel="stylesheet" href="./css/theme-chalk-index.css">
    <%--<link rel="stylesheet" href="./css/index.css" />--%>
    <!-- 引入组件库 -->
    <%--<link rel="stylesheet" href="./assets/icon/iconfont.css" />--%>
    <link href="./css/tabulator.min.css" rel="stylesheet" />
    <style>
        .el-dialog__body {
            padding: 10px 10px;
        }

        .el-dialog {
            margin-top: 1vh !important;
        }

        .tabulator .tabulator-header .tabulator-col {
            text-align: center;
        }

        .tabulator-tableHolder {
            background-color: #fff;
        }

        .border {
            border: 1px solid #808080;
            padding: 10px;
        }

        .el-input__inner {
            background-color: transparent;
        }

        .tabulator .tabulator-header {
            font-weight: inherit;
        }

        html {
            font-family: "Microsoft Yahei";
            font-size: 11px !important;
        }

        .el-form--inline .el-form-item__label {
            text-align: center !important;
        }

        .el-form--label-left .el-form-item__label {
            text-align: center !important;
        }
    </style>
</head>

<body>
    <asp:Label ID="lblUserName" runat="server" Visible="false"></asp:Label>
    <asp:Label ID="lbUserId" runat="server" Visible="false"></asp:Label>
    <asp:Label ID="lbUserCode" runat="server" Visible="false"></asp:Label>
    <div id="app">
        <el-container>  
                <el-container class="contain">
                    <el-header id="header" style="height:inherit !important">
                      
                        <el-form :model="form" label-position="left" label-width="80px" size="mini">
                            <el-row :gutter="16">
                                <el-col :span="4">
                                    <el-form-item label="请购人">
                                     <el-select v-model="form.FPersonCode" placeholder="请选择请购人">
                                        <el-option
                                            v-for="item in persons"
                                            :key="item.code"
                                            :label="item.name"
                                            :value="item.code">
                                        </el-option>
                                        </el-select>
                                    </el-form-item> 
                                </el-col> 
                                 <el-col :span="4">
                                    <el-form-item label="部门">
                                     <el-select v-model="form.FDeptCode" placeholder="请选择部门">
                                        <el-option
                                            v-for="item in dept"
                                            :key="item.code"
                                            :label="item.name"
                                            :value="item.code">
                                        </el-option>
                                        </el-select>
                                    </el-form-item> 
                                </el-col>
                                <el-col :span="4">
                                    <el-form-item label="单据日期">
                                      <el-date-picker
                                         v-model="form.FDate"
                                         type="date"
                                         placeholder="选择日期">
                                     </el-date-picker>
                                </el-col>  
                                <el-col :span="4">
                                    <el-form-item label="制单人">
                                     <el-select v-model="form.FUserName" placeholder="请选择制单人">
                                        <el-option
                                            v-for="item in user"
                                            :key="item.code"
                                            :label="item.name"
                                            :value="item.code">
                                        </el-option>
                                        </el-select>
                                    </el-form-item> 
                                </el-col>  
                            </el-row>
                            <el-row :gutter="16">
                                 <el-col :span="10">
                                     <el-form-item label="备注">
                                     <el-input
                                      type="textarea"
                                      :rows="1"
                                      placeholder="请输入备注信息"
                                      v-model="form.FMemo">
                                    </el-input>
                                </el-col>
                                 <el-col :span="6">
                                    <el-upload
                                      ref="upload"
                                      :show-file-list="false"
                                      :data={'SelectApi':'upload'}
                                      :on-success=uploadSuccess
                                      :before-upload=uploadBefore
                                      action="./uploadhandler.ashx">
                                      <el-button slot="trigger" size="mini" type="primary">选取文件</el-button>
                                      <el-button @click="checkTable" size="mini" type="warning" icon="el-icon-document-checked">检查表格</el-button>
                                      <el-button @click="clearTable" size="mini" type="danger" icon="el-icon-delete">清空记录</el-button>
                                      <el-button @click="saveTable" size="mini" type="success" icon="el-icon-check" :loading ="loading">保存记录</el-button>
                                    </el-upload>
                                </el-col> 
                             </el-row>
                       </el-form>
                    </el-header>
                    <el-main style="padding-top:0px">  
                        <el-card v-loading="loading">
                            <div style="width:100%" id="grid"></div>
                        </el-card>
                    </el-main>
                </el-container> 
           </el-container>
    </div>
    <script src="./js/moment.js"></script>
    <script src="./js/tableconfig.js"></script>
    <script src="./js/vue.js"></script>
    <script src="./js/element-ui-index.js"></script>
    <script src="./js/tabulator.js"></script>
    <script src="./js/jquery.min.js"></script>
    <script>
        var loginName = "<%=lblUserName.Text%>"
        var loginUserId = "<%=lbUserId.Text%>"
        var loginUserCode = "<%=lbUserCode.Text%>"
    </script>

    <script src="js/zkmt.js"></script>
</body>

</html>
