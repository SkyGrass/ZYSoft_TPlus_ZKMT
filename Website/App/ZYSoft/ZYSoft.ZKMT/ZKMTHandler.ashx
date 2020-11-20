<%@ WebHandler Language="C#" Class="ZKMTHandler" %>

using System;
using System.Web;
using System.Data;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Xml;
using System.Net;
using System.IO;
public class ZKMTHandler : IHttpHandler
{
    public class Result
    {
        public string status { get; set; }
        public object data { get; set; }
        public string msg { get; set; }
    }

    public class QueryForm
    {
        public string cid { get; set; }
        public string batch { get; set; }
    }

    public class PostForm
    {
        /// <summary>
        /// 
        /// </summary>
        public string FUserCode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FUserName { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FDate { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FPersonCode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FDeptCode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FMemo { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public List<Body> Entry { get; set; }
    }

    public class Body
    {
        /// <summary>
        /// 
        /// </summary>
        public string FInvCode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FProjectCode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public decimal FQuantity { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FRequireDate { get; set; }
    }

    public class CkPostForm
    {
        /// <summary>
        /// 
        /// </summary>
        public string FUserCode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FUserName { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FDate { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FPersonCode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FDeptCode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FMemo { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FProjectCode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FWhCode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public List<CkBody> Entry { get; set; }
    }
    public class CkBody
    {
        /// <summary>
        /// 
        /// </summary>
        public string FInvCode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public decimal FQuantity { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FPurRequstBillNo { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int FPurRequstBillID { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int FPurRequstBillEntryID { get; set; }
    }

    public class UpdateForm
    {
        public int id { get; set; }
        public int iEntryId { get; set; }
        public decimal iTaxPrice { get; set; }
    }

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


    public void ProcessRequest(HttpContext context)
    {
        ZYSoft.DB.Common.Configuration.ConnectionString = LoadXML("ConnectionString");
        context.Response.ContentType = "text/plain";
        if (context.Request.Form["SelectApi"] != null)
        {
            string result = ""; string methodName = "";
            switch (context.Request.Form["SelectApi"].ToLower())
            {
                case "getconnect":
                    result = ZYSoft.DB.Common.Configuration.ConnectionString;
                    break;
                case "getperson":
                    result = GetApplicant();
                    break;
                case "getdept":
                    result = GetDept();
                    break;
                case "getproject":
                    result = GetProject();
                    break;
                case "getstock":
                    result = GetStock();
                    break;
                case "getprojectdetail":
                    string idProject = context.Request.Form["idProject"] ?? "-1";
                    string idStock = context.Request.Form["idStock"] ?? "-1";
                    bool noZero = bool.Parse(context.Request.Form["noZero"]);
                    result = GetProjectDetail(idProject, idStock, noZero);
                    break;
                case "saveqgd":
                    string formData = context.Request.Form["formData"] ?? "";
                    addLogErr("saveqgd", formData);
                    methodName = LoadXML("Method");
                    result = SaveBill(JsonConvert.DeserializeObject<PostForm>(formData), methodName);
                    break;
                case "saveck":
                    formData = context.Request.Form["formData"] ?? "";
                    addLogErr("saveck", formData);
                    methodName = LoadXML("MethodOut");
                    result = SaveBill(JsonConvert.DeserializeObject<CkPostForm>(formData), methodName);
                    break;
                case "getcgorder":
                    string ordercode = context.Request.Form["ordercode"] ?? "";
                    string startdate = context.Request.Form["startdate"] ?? DateTime.Now.ToString("yyyy-MM-dd");
                    string enddate = context.Request.Form["enddate"] ?? DateTime.Now.ToString("yyyy-MM-dd");
                    string vendor = context.Request.Form["vendor"] ?? "";
                    string cinv = context.Request.Form["cinv"] ?? "";
                    result = GetPurchaseOrder(ordercode, startdate, enddate, vendor, cinv);
                    break;
                case "savecgd":
                    formData = context.Request.Form["formdata"] ?? "";
                    addLogErr("saveck", formData);
                    result = UpdatePrice(JsonConvert.DeserializeObject<List<UpdateForm>>(formData));
                    break;
                default: break;
            }
            context.Response.Write(result);
        }
    }

    /// <summary>
    /// 部门
    /// </summary>
    /// <returns></returns>
    public string GetDept()
    {
        var list = new List<Result>();
        try
        {
            string sql = string.Format(@"SELECT id ,code ,name FROM dbo.AA_Department WHERE disabled =0");
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
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
    /// 请购人
    /// </summary>
    /// <returns></returns>
    public string GetApplicant()
    {
        var list = new List<Result>();
        try
        {
            string sql = string.Format(@"SELECT id ,code,name FROM dbo.AA_Person WHERE disabled =0");
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
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
    /// 项目
    /// </summary>
    /// <returns></returns>
    public string GetProject()
    {
        var list = new List<Result>();
        try
        {
            string sql = string.Format(@"select id ,code,name from AA_Project where disabled=0");
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
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
    /// 仓库
    /// </summary>
    /// <returns></returns>
    public string GetStock()
    {
        var list = new List<Result>();
        try
        {
            string sql = string.Format(@"SELECT id ,code,name FROM dbo.AA_Warehouse WHERE disabled =0");
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
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
    /// 存货
    /// </summary>
    /// <returns></returns>
    public string GetInv()
    {
        var list = new List<Result>();
        try
        {
            string sql = string.Format(@"SELECT t1.id FItemID,t1.code FInvCode,t1.name FInvName,specification FInvStd,T2.name FUnitName
                FROM dbo.AA_Inventory  T1 JOIN dbo.AA_Unit T2 ON T1.idunit=T2.ID WHERE  t1.disabled=0 ");
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
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
    public string GetCurrentStock(string invId)
    {
        var list = new List<Result>();
        try
        {
            string sql = string.Format(@"SELECT sum(CanuseBaseQuantity)CanuseBaseQuantity from ST_CurrentStock  where idinventory = '{0}'", invId);
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
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
    public string GetProjectDetail(string idProject, string idStock, bool noZero = false)
    {
        var list = new List<Result>();
        try
        {
            string sql = string.Format(@"select t2.idproject, t1.id FID,T2.id FEntryID,t1.code FBillNo,t1.voucherdate FDate,T3.code FInvNumber,t3.name FInvName,t3.specification FInvStd,T4.name FUnit,       
                    CONVERT(FLOAT,t2.quantity) FQty,CONVERT(FLOAT,ISNULL(T2.pubuserdefdecm1,0)) FOutQty,CONVERT(FLOAT,t2.quantity - ISNULL(T2.pubuserdefdecm1,0))  FUnOutQty,       
                    isnull((SELECT CONVERT(FLOAT,SUM(T5.CanuseBaseQuantity)) FROM ST_CurrentStock T5 WHERE T5.idinventory=T2.idinventory and t5.idwarehouse='{1}'),0) FStockQty       
                    from Pu_PurchaseRequisition t1 join Pu_PurchaseRequisition_b t2 on t1.id=t2.idPurchaseRequisitionDTO       
                    LEFT JOIN AA_Inventory T3 ON T2.idinventory=T3.id       
                    LEFT JOIN AA_Unit T4 ON T3.idunit=T4.ID       
                    where t2.quantity - ISNULL(T2.pubuserdefdecm1,0)  > 0 AND T2.idproject='{0}'", idProject, idStock);

            if (noZero)
            {
                sql = string.Format(@"select * from (select t2.idproject, t1.id FID,T2.id FEntryID,t1.code FBillNo,t1.voucherdate FDate,T3.code FInvNumber,t3.name FInvName,t3.specification FInvStd,T4.name FUnit,       
                    CONVERT(FLOAT,t2.quantity) FQty,CONVERT(FLOAT,ISNULL(T2.pubuserdefdecm1,0)) FOutQty,CONVERT(FLOAT,t2.quantity - ISNULL(T2.pubuserdefdecm1,0))  FUnOutQty,       
                    isnull((SELECT CONVERT(FLOAT,SUM(T5.CanuseBaseQuantity)) FROM ST_CurrentStock T5 WHERE T5.idinventory=T2.idinventory and t5.idwarehouse='{1}'),0) FStockQty       
                    from Pu_PurchaseRequisition t1 join Pu_PurchaseRequisition_b t2 on t1.id=t2.idPurchaseRequisitionDTO       
                    LEFT JOIN AA_Inventory T3 ON T2.idinventory=T3.id       
                    LEFT JOIN AA_Unit T4 ON T3.idunit=T4.ID       
                    where t2.quantity - ISNULL(T2.pubuserdefdecm1,0)  > 0 AND T2.idproject='{0}') as t where t.FStockQty >0 ", idProject, idStock);
            }
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
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

    public string GetPurchaseOrder(string code, string startdate, string enddate, string verdor = "", string cinv = "")
    {
        var list = new List<Result>();
        try
        {
            string sql = string.Format(@"select t1.id,t1.code,t1.voucherdate,t3.code as VendorCode,t3.name VendorName,
                                    T2.id iEntryID, t4.code cInvCode,t4.name cInvName,t4.specification cInvStd,
                                    convert(float,t2.quantity) iQuantity,convert(float,t2.taxRate ) iTaxRate,
                                    convert(float,t2.baseTaxPrice ) iTaxPrice,convert(float,t2.taxAmount ) iTaxAmount
                                    from PU_PurchaseOrder  t1 join pu_purchaseOrder_b t2 on t1.id=t2.idPurchaseOrderDTO
                                    left join AA_Partner t3 on t1.idpartner=t3.id
                                    left join AA_Inventory t4 on t2.idinventory=t4.id
                                    where  (t3.code like '%{0}%' or t3.name like '%{0}%') and voucherdate between '{1}' and '{2}'", verdor, startdate, enddate);
            if (!string.IsNullOrEmpty(cinv))
            {
                sql += string.Format(" and (t4.code like '%{0}%' or t4.name like '%{0}%')", cinv);
            }
            if (!string.IsNullOrEmpty(code))
            {
                sql += string.Format(" and t1.code like '%{0}%'  ", code);
            }

            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
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

    public string UpdatePrice(List<UpdateForm> list)
    {
        string errMsg = "";
        List<string> sqlList = new List<string>();
        foreach (UpdateForm form in list)
        {
            sqlList.Add(string.Format(@"exec P_ZYSoft_UpdatePurchaseOrderPrice {0},{1},{2}", form.id,
       form.iEntryId, form.iTaxPrice));
        }
        int row = ZYSoft.DB.BLL.Common.ExecuteSQLTran(sqlList, ref errMsg);
        return JsonConvert.SerializeObject(new
        {
            status = row > 0 ? "success" : "error",
            msg = row > 0 ? "更新完成!" : "更新失败!"
        });
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

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}