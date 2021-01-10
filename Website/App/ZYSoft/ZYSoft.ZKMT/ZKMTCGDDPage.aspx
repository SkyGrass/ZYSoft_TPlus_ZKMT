<%@ Page Language="C#" AutoEventWireup="true" %>

<%-- CodeFile="ZKMTCGDDPage.aspx.cs" Inherits="App_ZYSoft_ZYSoft_ZKMT_ZKMTCGDDPage" --%>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <title>请购单生成采购订单</title>
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

        .datepickercss1 {
            width: inherit !important;
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
                            <el-row :gutter="17"> 
                                <el-col :span="4">
                                     <el-form-item label="编码">
                                         <el-input
                                          :rows="1"
                                          placeholder="请输入项目编码"
                                          v-model="keyword_code">
                                        </el-input>
                                    </el-form-item>  
                                </el-col>
                                 <el-col :span="4"> 
                                     <el-form-item label="无需采购">
                                     <el-select v-model="poflag" style="width: 100%;">
                                        <el-option
                                            v-for="item in pomark"
                                            :key="item.code"
                                            :label="item.name"
                                            :value="item.code">
                                        </el-option>
                                    </el-select>
                                    </el-form-item>
                                </el-col>  
                                <el-col :span="4">
                                     <el-form-item label="项目机构">
                                         <el-input
                                          :rows="1"
                                          placeholder="请输入项目机构名称"
                                          v-model="keyword_project">
                                        </el-input>
                                     </el-form-item>  
                                </el-col>
                            </el-row> 
                               <el-row :gutter="16">
                                <el-col :span="4">
                                     <el-form-item label="存货">
                                         <el-input
                                          :rows="1"
                                          placeholder="请输入存货编码、名称、规格"
                                          v-model="keyword">
                                        </el-input>
                                     </el-form-item>  
                                </el-col>
                                <el-col :span="5">
                                    <el-form-item label="日期">
                                        <el-date-picker
                                            class="datepickercss"
                                            v-model="keyword_reqdate"
                                            type="daterange" 
                                            format="yyyy-MM-dd"
                                            value-format="yyyy-MM-dd"
                                            :clearable="false"
                                            placeholder="选择请购日期">
                                        </el-date-picker>
                                    </el-form-item>  
                                </el-col>
                             </el-row>
                             <el-row :gutter="16">
                                 <el-col :span="12">
                                        <el-form-item label="项目">
                                         <el-select v-model="codeProject" multiple placeholder="请选择项目" filterable clearable style="width: 100%;">
                                            <el-option
                                                v-for="item in project"
                                                :key="item.id"
                                                :label="item.name"
                                                :value="item.id">
                                            </el-option>
                                            </el-select>
                                        </el-form-item> 
                                </el-col> 
                             </el-row> 
                             <el-row :gutter="16">
                               <el-col :span="12">
                                     <el-form-item label="请购人">
                                        <el-select v-model="keyword_requser" multiple placeholder="请选择请购人" filterable clearable style="width: 100%;">
                                        <el-option
                                            v-for="item in poperson"
                                            :key="item.code"
                                            :label="item.name"
                                            :value="item.name">
                                        </el-option>
                                        </el-select>
                                    </el-form-item>
                                </el-col>
                            </el-row>
                            <el-row :gutter="16">
                                <el-col :span="12">
                                     <el-form-item label="请购单号"> 
                                        <el-select v-model="keyword_billno" multiple clearable placeholder="请输入请购单号" style="width: 100%;">
                                        <el-option
                                            v-for="item in billno"
                                            :key="item.code"
                                            :label="item.name"
                                            :value="item.code">
                                        </el-option>
                                        </el-select>
                                    </el-form-item>  
                                </el-col>
                                <el-col :span="2"> 
                                    <el-button @click="queryRecord" size="mini" type="primary" icon="el-icon-search" :loading ="loading" >查询记录</el-button> 
                                 </el-col>
                            </el-row>
                             <el-row :gutter="16">
                                 <el-col :span="4">
                                    <el-form-item label="制单人">
                                     <el-select v-model="form.FUserName" placeholder="请选择制单人"  style="width: 100%;">
                                        <el-option
                                            v-for="item in user"
                                            :key="item.code"
                                            :label="item.name"
                                            :value="item.code">
                                        </el-option>
                                        </el-select>
                                    </el-form-item> 
                                </el-col>
                                    <el-col :span="4">
                                    <el-form-item label="部门">
                                     <el-select v-model="form.FDeptCode" placeholder="请选择部门" style="width: 100%;">
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
                                    </el-form-item>  
                                </el-col>
                             </el-row>
                             <el-row :gutter="16">
                                <el-col :span="8">
                                     <el-form-item label="备注">
                                        <el-input
                                          type="textarea"
                                          :rows="1"
                                          placeholder="请输入备注信息"
                                          v-model="form.FMemo">
                                        </el-input>
                                    </el-form-item>
                                </el-col> 
                                    <el-col :span="2"> 
                                        <el-button @click="updateMark" size="mini" type="success" icon="el-icon-s-custom" :loading ="loading" >选取供应商</el-button> 
                                    </el-col> 
                                    <el-col :span="2"> 
                                        <el-button @click="saveTable" size="mini" type="success" icon="el-icon-refresh" :loading ="loading" >提交单据</el-button> 
                                    </el-col>
                             </el-row>
                       </el-form>
                    </el-header>
                    <el-main style="padding-top:0px">  
                        <el-card v-loading="loading">
                            <div style="width:100%" id="grid"></div>
                        </el-card>
                    </el-main>
                    <el-dialog title="供应商选择" :visible.sync="dialogTableVisible" :close-on-click-modal="false" :destroy-on-close="true">
                            <el-input placeholder="请在此处输入编码或者名称进行检索" v-model="keyword_partner" @keyup.enter.native="getPartner" style="margin:10px 0">
                            <el-button slot="append" icon="el-icon-search" @click="getPartner"></el-button>
                            </el-input>
                        <el-table
                            border
                            size="mini"
                            :data="partnerList"
                            max-height="400"
                            highlight-current-row
                            ref="singleTable"
                            @current-change="handleCurrentChange">
                        <el-table-column property="code" align="center" label="供应商编码"></el-table-column>
                        <el-table-column property="name" align="center" label="供应商名称"></el-table-column> 
                        </el-table>
                        <div slot="footer" class="dialog-footer">
                        <el-button @click="dialogTableVisible = false">取 消</el-button>
                        <el-button type="primary" @click="confirmMark">确 定</el-button>
                        </div>
                 </el-dialog>
                </el-container> 
           </el-container>
    </div>
    <script src="./js/moment.js"></script>
    <script src="./js/tablecgddconfig.js"></script>
    <script src="./js/vue.js"></script>
    <script src="./js/element-ui-index.js"></script>
    <script src="./js/tabulator.js"></script>
    <script src="./js/jquery.min.js"></script>
    <script>
        var loginName = "<%=lblUserName.Text%>"
        var loginUserId = "<%=lbUserId.Text%>"
        var loginUserCode = "<%=lbUserCode.Text%>"
    </script>

    <script src="js/zkmt_cgdd.js"></script>
</body>

</html>
