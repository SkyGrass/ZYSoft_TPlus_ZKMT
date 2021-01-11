<%@ WebHandler Language="C#" Class="ZKMTCGDDHandler" %>

using System;
using System.Web;
using System.Data;
using System.Linq;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Xml;
using System.Net;
using System.IO;

public class ZKMTCGDDHandler : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        ZYSoft.DB.Common.Configuration.ConnectionString = LoadXML("ConnectionString");
        context.Response.ContentType = "text/plain";
        if (context.Request.Form["SelectApi"] != null)
        {
            string result = "";
            switch (context.Request.Form["SelectApi"].ToLower())
            {
                case "getpartner":
                    string keyword_partner = context.Request.Form["keyword"] ?? "";
                    result = GetPartner(keyword_partner);
                    break;
                case "getpobillno":
                    string keyword_billno = context.Request.Form["keyword"] ?? "";
                    result = GetBillNo(keyword_billno);
                    break;
                case "getpoperson":
                    string keyword_person = context.Request.Form["keyword"] ?? "";
                    result = GetPerson(keyword_person);
                    break;
                case "getprojectdetail":
                    string idProject = context.Request.Form["idProject"] ?? "";
                    string projectCode = context.Request.Form["projectCode"] ?? "";
                    string poflag = context.Request.Form["poflag"] ?? "0";
                    string keyword_project = context.Request.Form["keyword_project"] ?? "";
                    string keyword = context.Request.Form["keyword"] ?? "";
                    string billno = context.Request.Form["billno"] ?? "";
                    string requser = context.Request.Form["requser"] ?? "";
                    string reqdate_begin = context.Request.Form["reqdate_begin"] ?? "";
                    string reqdate_end = context.Request.Form["reqdate_end"] ?? "";
                    result = GetProjectDetail(idProject, poflag, keyword, keyword_project, projectCode, billno, requser, reqdate_begin, reqdate_end);
                    break;
                case "unpomark":
                    string ids = context.Request.Form["ids"] ?? string.Empty;
                    string flag = (context.Request.Form["flag"] ?? "0").Equals("0") ? "否" : "是"; //不采购更新为是
                    result = UnPOMark(ids.Split(','), flag);
                    break;
                case "savepo":
                    string formData = context.Request.Form["formData"] ?? "";
                    addLogErr("saveck", formData);
                    string methodName = LoadXML("MethodPO");
                    result = SaveBill(JsonConvert.DeserializeObject<PucherOrder>(formData), methodName);
                    break;
                default: break;
            }
            context.Response.Write(result);
        }
    }

    /// <summary>
    /// 获取供应商
    /// </summary>
    /// <returns></returns>
    public string GetPartner(string keyword)
    {
        var list = new List<Result>();
        try
        {
            string sqlWhere = "";
            string sql = string.Format(@"select  id ,code ,name ,shorthand as zjf from dbo.aa_partner where disabled =0 and (partnertype=228 or partnertype=226)");
            if (!string.IsNullOrEmpty(keyword))
            {
                sqlWhere = string.Format(@" and (code like '%{0}%' or name like '%{0}%' or shorthand like '%{0}%')", keyword);
            }
            else
            {
                sql = string.Format(@"select top 10 id ,code ,name ,shorthand as zjf from dbo.aa_partner where disabled =0 and (partnertype=228 or partnertype=226)");
            }
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql + sqlWhere);
            return JsonConvert.SerializeObject(new
            {
                status = dt.Rows.Count > 0 ? "success" : "error",
                data = dt,
                msg = ""
            });
        }
        catch (Exception ex)
        {
            return JsonConvert.SerializeObject(new
            {
                status = "error",
                data = new List<string>(),
                msg = ex.Message
            });
        }
    }

    /// <summary>
    /// 获取请购单号
    /// </summary>
    /// <returns></returns>
    public string GetBillNo(string keyword)
    {
        var list = new List<Result>();
        try
        {
            string sqlWhere = "";
            string sql = string.Format(@"select  distinct  t1.code,t1.code as name                     
                                        from Pu_PurchaseRequisition t1 join Pu_PurchaseRequisition_b t2 on t1.id=t2.idPurchaseRequisitionDTO   
                                            where   t2.quantity - ISNULL(T2.baseCumExecuteQuantity ,0)  > 0 AND ISNULL(T1.auditor,'') <>''");
            if (!string.IsNullOrEmpty(keyword))
            {
                sqlWhere = string.Format(@" and t1.code like '%{0}%'", keyword);
            }

            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql + sqlWhere + " order by t1.code");
            return JsonConvert.SerializeObject(new
            {
                status = dt.Rows.Count > 0 ? "success" : "error",
                data = dt,
                msg = ""
            });
        }
        catch (Exception ex)
        {
            return JsonConvert.SerializeObject(new
            {
                status = "error",
                data = new List<string>(),
                msg = ex.Message
            });
        }
    }

    /// <summary>
    /// 获取请购人
    /// </summary>
    /// <returns></returns>
    public string GetPerson(string keyword)
    {
        var list = new List<Result>();
        try
        {
            string sqlWhere = "";
            string sql = string.Format(@"select distinct T3.name,t3.code
                                    from Pu_PurchaseRequisition t1 join Pu_PurchaseRequisition_b t2 on t1.id=t2.idPurchaseRequisitionDTO
                                    left outer join AA_Person t3 on t3.id=t1.idrequisitionperson 
                                    where   t2.quantity - ISNULL(T2.baseCumExecuteQuantity ,0)  > 0 AND ISNULL(T1.auditor,'') <>'' ");
            if (!string.IsNullOrEmpty(keyword))
            {
                sqlWhere = string.Format(@" and (t3.name like '%{0}% or t3.code like '%{0}%' or t3.shorthand like '%{0}%')'", keyword);
            }

            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql + sqlWhere + " order by t3.name ");
            return JsonConvert.SerializeObject(new
            {
                status = dt.Rows.Count > 0 ? "success" : "error",
                data = dt,
                msg = ""
            });
        }
        catch (Exception ex)
        {
            return JsonConvert.SerializeObject(new
            {
                status = "error",
                data = new List<string>(),
                msg = ex.Message
            });
        }
    }

    /// <summary>
    /// 库存
    /// </summary>
    /// <returns></returns>
    public string GetProjectDetail(string idProject, string poflag = "否",
        string keyword = "", string keyword_project = "", string projectcode = "",
        string billno = "", string requser = "", string reqdate_begin = "", string reqdate_end = "")
    {
        var list = new List<Result>();
        try
        {
            string sqlWhere = "";
            if (!string.IsNullOrEmpty(idProject))
            {
                sqlWhere += string.Format(@" and t2.idproject in ({0}) ", idProject);
            }
            if (!string.IsNullOrEmpty(keyword))
            {
                sqlWhere += string.Format(@" and (t3.code like ''%{0}%'' or t3.name like ''%{0}%'' or t3.specification like ''%{0}%'')", keyword);
            }
            if (!string.IsNullOrEmpty(keyword_project))
            {
                sqlWhere += string.Format(@" and t2.pubuserdefnvc6 like ''%{0}%''", keyword_project);
            }

            if (poflag != "-1")
            {
                poflag = poflag.Equals("1") ? "是" : "否";
                sqlWhere += string.Format(@" and isnull(t2.pubuserdefnvc7,''否'') = ''{0}''", poflag);
            }

            if (!string.IsNullOrEmpty(projectcode))
            {
                sqlWhere += string.Format(@" and t6.code like ''%{0}%''", projectcode);
            }

            if (!string.IsNullOrEmpty(billno))
            {
                sqlWhere += string.Format(@" and t1.code in ({0})", billno);
            }

            if (!string.IsNullOrEmpty(requser))
            {
                sqlWhere += string.Format(@" and t7.name in ({0})", requser);
            }

            if (!string.IsNullOrEmpty(reqdate_begin))
            {
                sqlWhere += string.Format(@" and t1.voucherdate >= ''{0} 00:00:00''", reqdate_begin);
            }

            if (!string.IsNullOrEmpty(reqdate_end))
            {
                sqlWhere += string.Format(@" and t1.voucherdate <= ''{0} 23:59:59''", reqdate_end);
            }

            if (sqlWhere.StartsWith(" and "))
            {
                sqlWhere = sqlWhere.Remove(0, 4);
            }

            string sql = string.Format(@"exec P_ZYSoft_GetPurReqToPO '{0}'", sqlWhere);
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
            List<ProjectDetail> source = ToList<ProjectDetail>(dt);
            return JsonConvert.SerializeObject(new
            {
                status = dt.Rows.Count > 0 ? "success" : "error",
                data = source,
                msg = ""
            });
        }
        catch (Exception ex)
        {
            return JsonConvert.SerializeObject(new
            {
                status = "error",
                data = new List<string>(),
                msg = ex.Message
            });
        }
    }

    public static string UnPOMark(string[] ids, string flag = "否")
    {
        string errMsg = ""; int effectRow = 0;
        try
        {
            if (ids != null && ids.Length > 0)
            {
                List<string> sqlList = new List<string>();
                new List<string>(ids).ForEach(item =>
                {
                    sqlList.Add(string.Format(@"update Pu_PurchaseRequisition_b set pubuserdefnvc7 ='{1}' WHERE id='{0}'", item, flag));
                });
                if (sqlList.Count > 0)
                {
                    effectRow = ZYSoft.DB.BLL.Common.ExecuteSQLTran(sqlList, ref errMsg);
                    if (effectRow > 0)
                    {
                        errMsg = "更新成功!";
                    }
                }
            }
            else
            {
                errMsg = "没有发现要更新的数据行!";
            }

            return JsonConvert.SerializeObject(new
            {
                status = effectRow > 0 ? "success" : "error",
                data = new string[] { },
                msg = errMsg
            });
        }
        catch (Exception e)
        {
            return JsonConvert.SerializeObject(new
            {
                status = "error",
                data = new string[] { },
                msg = "更新过程发生异常!" + e.Message
            });
        }
    }

    public bool BeforeSave<T>(T formData, ref string msg)
    {
        return true;
    }


    /*保存单据*/
    public string SaveBill<T>(T formData, string methosName)
    {
        try
        {
            string errMsg = "";
            if (BeforeSave(formData, ref errMsg))
            {
                var WsUrl = LoadXML("WsUrl");
                var formDatas = new List<FormItemModel>();
                //添加文本
                formDatas.Add(new FormItemModel()
                {
                    Key = "MethodName",
                    Value = methosName
                });          //添加文本
                formDatas.Add(new FormItemModel()
                {
                    Key = "JSON",
                    Value = JsonConvert.SerializeObject(formData)
                });

                addLogErr("SaveBill", JsonConvert.SerializeObject(formDatas));

                //提交表单
                var json = doPost(WsUrl, formDatas);
                TResult result = JsonConvert.DeserializeObject<TResult>(json);
                return JsonConvert.SerializeObject(new
                {
                    status = result.Result == "Y" ? "success" : "error",
                    data = "",
                    msg = result.Result == "Y" ? "生成单据成功!" : result.Message
                });
            }
            else
            {
                return JsonConvert.SerializeObject(new
                {
                    status = "error",
                    data = "",
                    msg = "保存单据失败!"
                });
            }
        }
        catch (Exception)
        {
            return JsonConvert.SerializeObject(new
            {
                status = "error",
                data = "",
                msg = "生成单据发生异常!"
            });
        }
    }

    public string doPost(string url, List<FormItemModel> formItems, CookieContainer cookieContainer = null, string refererUrl = null,
        System.Text.Encoding encoding = null, int timeOut = 20000)
    {
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
        #region 初始化请求对象
        request.Method = "POST";
        request.Timeout = timeOut;
        request.Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8";
        request.KeepAlive = true;
        request.UserAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.57 Safari/537.36";
        if (!string.IsNullOrEmpty(refererUrl))
            request.Referer = refererUrl;
        if (cookieContainer != null)
            request.CookieContainer = cookieContainer;
        #endregion

        string boundary = "----" + DateTime.Now.Ticks.ToString("x");//分隔符
        request.ContentType = string.Format("multipart/form-data; boundary={0}", boundary);
        //请求流
        var postStream = new MemoryStream();
        #region 处理Form表单请求内容
        //是否用Form上传文件
        var formUploadFile = formItems != null && formItems.Count > 0;
        if (formUploadFile)
        {
            //文件数据模板
            string fileFormdataTemplate =
                "\r\n--" + boundary +
                "\r\nContent-Disposition: form-data; name=\"{0}\"; filename=\"{1}\"" +
                "\r\nContent-Type: application/octet-stream" +
                "\r\n\r\n";
            //文本数据模板
            string dataFormdataTemplate =
                "\r\n--" + boundary +
                "\r\nContent-Disposition: form-data; name=\"{0}\"" +
                "\r\n\r\n{1}";
            foreach (var item in formItems)
            {
                string formdata = null;
                if (item.IsFile)
                {
                    //上传文件
                    formdata = string.Format(
                        fileFormdataTemplate,
                        item.Key, //表单键
                        item.FileName);
                }
                else
                {
                    //上传文本
                    formdata = string.Format(
                        dataFormdataTemplate,
                        item.Key,
                        item.Value);
                }

                //统一处理
                byte[] formdataBytes = null;
                //第一行不需要换行
                if (postStream.Length == 0)
                    formdataBytes = System.Text.Encoding.UTF8.GetBytes(formdata.Substring(2, formdata.Length - 2));
                else
                    formdataBytes = System.Text.Encoding.UTF8.GetBytes(formdata);
                postStream.Write(formdataBytes, 0, formdataBytes.Length);

                //写入文件内容
                if (item.FileContent != null && item.FileContent.Length > 0)
                {
                    using (var stream = item.FileContent)
                    {
                        byte[] buffer = new byte[1024];
                        int bytesRead = 0;
                        while ((bytesRead = stream.Read(buffer, 0, buffer.Length)) != 0)
                        {
                            postStream.Write(buffer, 0, bytesRead);
                        }
                    }
                }
            }
            //结尾
            var footer = System.Text.Encoding.UTF8.GetBytes("\r\n--" + boundary + "--\r\n");
            postStream.Write(footer, 0, footer.Length);
        }
        else
        {
            request.ContentType = "application/x-www-form-urlencoded";
        }
        #endregion

        request.ContentLength = postStream.Length;

        #region 输入二进制流
        if (postStream != null)
        {
            postStream.Position = 0;
            //直接写入流
            Stream requestStream = request.GetRequestStream();

            byte[] buffer = new byte[1024];
            int bytesRead = 0;
            while ((bytesRead = postStream.Read(buffer, 0, buffer.Length)) != 0)
            {
                requestStream.Write(buffer, 0, bytesRead);
            }
            postStream.Close();//关闭文件访问
        }
        #endregion

        HttpWebResponse response = (HttpWebResponse)request.GetResponse();
        if (cookieContainer != null)
        {
            response.Cookies = cookieContainer.GetCookies(response.ResponseUri);
        }

        using (Stream responseStream = response.GetResponseStream())
        {
            using (StreamReader myStreamReader = new StreamReader(responseStream, encoding ?? System.Text.Encoding.UTF8))
            {
                string retString = myStreamReader.ReadToEnd();
                return retString;
            }
        }
    }


    public static void addLogErr(string SPName, string ErrDescribe)
    {
        string tracingFile = "C:/inetpub/wwwroot/log/";
        if (!Directory.Exists(tracingFile))
            Directory.CreateDirectory(tracingFile);
        string fileName = DateTime.Now.ToString("yyyyMMdd") + ".txt";
        tracingFile += fileName;
        if (tracingFile != string.Empty)
        {
            FileInfo file = new FileInfo(tracingFile);
            StreamWriter debugWriter = new StreamWriter(file.Open(FileMode.Append, FileAccess.Write, FileShare.ReadWrite));
            debugWriter.WriteLine(SPName + " (" + DateTime.Now.ToString() + ") " + " :");
            debugWriter.WriteLine(ErrDescribe);
            debugWriter.WriteLine();
            debugWriter.Flush();
            debugWriter.Close();
        }
    }


    public string LoadXML(string key)
    {
        string return_value = string.Empty;
        try
        {
            string filename = HttpContext.Current.Request.PhysicalApplicationPath + @"zysoftweb.config";
            addLogErr("LoadXML", filename);
            XmlDocument xmldoc = new XmlDocument();
            xmldoc.Load(filename);
            XmlNode node = xmldoc.SelectSingleNode("/configuration/appSettings");


            foreach (XmlElement el in node)//读元素值 
            {
                if (el.Attributes["key"].Value.ToLower().Equals(key.ToLower()))
                {
                    return_value = el.Attributes["value"].Value;
                    break;
                }
            }
            return return_value;
        }
        catch (Exception e)
        {
            addLogErr("LoadXML", e.Message);
            return return_value;
        }
    }

    public static List<T> ToList<T>(DataTable dt)
    {
        var dataColumn = dt.Columns.Cast<DataColumn>().Select(c => c.ColumnName).ToList();

        var properties = typeof(T).GetProperties();
        string columnName = string.Empty;

        return dt.AsEnumerable().Select(row =>
        {
            var t = System.Activator.CreateInstance<T>();
            foreach (var p in properties)
            {
                columnName = p.Name;
                if (dataColumn.Contains(columnName))
                {
                    if (!p.CanWrite)
                        continue;

                    object value = row[columnName];
                    System.Type type = p.PropertyType;

                    if (value != System.DBNull.Value)
                    {
                        p.SetValue(t, System.Convert.ChangeType(value, type), null);
                    }
                }
            }
            return t;
        }).ToList();
    }

    #region
    public class ProjectDetail
    {
        /// <summary>        ///         /// </summary>        public int FIndex { get; set; }
        /// <summary>        ///         /// </summary>        public int idproject { get; set; }
        /// <summary>        ///         /// </summary>        public string FProjectCode { get; set; }
        /// <summary>        ///         /// </summary>        public string FProjectName { get; set; }
        /// <summary>        ///         /// </summary>        public int FID { get; set; }
        /// <summary>        ///         /// </summary>        public int FEntryID { get; set; }
        /// <summary>        ///         /// </summary>        public string FBillNo { get; set; }
        /// <summary>        ///         /// </summary>        public string FDate { get; set; }
        /// <summary>        ///         /// </summary>        public string FRequisitionPerson { get; set; }
        /// <summary>        ///         /// </summary>        public int idinventory { get; set; }
        /// <summary>        ///         /// </summary>        public string FInvNumber { get; set; }
        /// <summary>        ///          /// </summary>        public string FInvName { get; set; }
        /// <summary>        ///         /// </summary>        public string FInvStd { get; set; }
        /// <summary>        ///         /// </summary>        public string FUnit { get; set; }
        /// <summary>        ///         /// </summary>        public string FBrand { get; set; }
        /// <summary>        ///         /// </summary>        public decimal FQty { get; set; }
        /// <summary>        ///         /// </summary>        public decimal FStockQty { get; set; }
        /// <summary>        ///         /// </summary>        public decimal FSafeQty { get; set; }
        /// <summary>        ///         /// </summary>        public decimal FUnPOQty { get; set; }
        /// <summary>        ///         /// </summary>
        public string pubuserdefnvc7 { get; set; }
    }
    #endregion

    #region 提交数据 
    public class PucherOrder
    {
        /// <summary>
        /// 当前登录用户编码
        /// </summary>
        public string FUserCode { get; set; }

        /// <summary>
        /// 当前登录用户名称
        /// </summary>
        public string FUserName { get; set; }
        /// <summary>
        /// 制单日期
        /// </summary>
        public string FDate { get; set; }
        /// <summary>
        /// 业务员编码
        /// </summary>
        public string FPersonCode { get; set; }

        /// <summary>
        ///  部门编码
        /// </summary>
        public string FDeptCode { get; set; }

        /// <summary>
        /// 备注
        /// </summary>
        public string FMemo { get; set; }
        /// <summary>
        /// 明细
        /// </summary>
        public List<PucherOrderEntry> Entry { get; set; }
    }

    public class PucherOrderEntry
    {
        /// <summary>
        /// 供应商编码 
        /// </summary>
        public string FVenderCode { get; set; }

        /// <summary>
        /// 源单ID 
        /// </summary>
        public string FSourceBillID { get; set; }

        /// <summary>
        /// 源单单号 
        /// </summary>
        public string FSourceBillNo { get; set; }

        /// <summary>
        /// 源单明细ID 
        /// </summary>
        public string FSourceBillEntryID { get; set; }

        /// <summary>
        /// 源单明细行号
        /// </summary>
        public string FSourceBillEntryRowNo { get; set; }
        /// <summary>
        /// 存货编码
        /// </summary>
        public string FInvCode { get; set; }

        /// <summary>
        /// 项目编码 
        /// </summary>
        public string FProjectCode { get; set; }

        /// <summary>
        ///  采购数量
        /// </summary>
        public decimal FQuantity { get; set; }

    }
    #endregion

    #region 
    public class Result
    {
        public string status { get; set; }
        public object data { get; set; }
        public string msg { get; set; }
    }
    #endregion

    /// <summary>
    /// 表单数据项
    /// </summary>
    public class FormItemModel
    {
        /// <summary>
        /// 表单键，request["key"]
        /// </summary>
        public string Key { set; get; }
        /// <summary>
        /// 表单值,上传文件时忽略，request["key"].value
        /// </summary>
        public string Value { set; get; }
        /// <summary>
        /// 是否是文件
        /// </summary>
        public bool IsFile
        {
            get
            {
                if (FileContent == null || FileContent.Length == 0)
                    return false;

                if (FileContent != null && FileContent.Length > 0 && string.IsNullOrWhiteSpace(FileName))
                    throw new Exception("上传文件时 FileName 属性值不能为空");
                return true;
            }
        }
        /// <summary>
        /// 上传的文件名
        /// </summary>
        public string FileName { set; get; }
        /// <summary>
        /// 上传的文件内容
        /// </summary>
        public Stream FileContent { set; get; }
    }

    public class TResult
    {
        public string Result { get; set; }
        public string Message { get; set; }
        public object Data { get; set; }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}