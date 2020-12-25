<%@ WebHandler Language="C#" Class="ZKMTCGDDHandler" %>

using System;
using System.Web;
using System.Data;
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
            string result = ""; string methodName = "";
            switch (context.Request.Form["SelectApi"].ToLower())
            {
                case "getpartner":
                    string keyword = context.Request.Form["keyword"] ?? "";
                    result = GetPartner(keyword);
                    break;
                case "getprojectdetail":
                    string idProject = context.Request.Form["idProject"] ?? "-1";
                    string idStock = context.Request.Form["idStock"] ?? "-1";
                    bool noZero = bool.Parse(context.Request.Form["noZero"]);
                    keyword = context.Request.Form["keyword"] ?? "";
                    string keyword_project = context.Request.Form["keyword_project"] ?? "";
                    result = GetProjectDetail(idProject, idStock, noZero, keyword, keyword_project);
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
    /// 库存
    /// </summary>
    /// <returns></returns>
    public string GetProjectDetail(string idProject, string idStock, bool noZero = false, string keyword = "", string keyword_project = "")
    {
        var list = new List<Result>();
        try
        {
            string sqlWhere = "";
            if (!string.IsNullOrEmpty(keyword))
            {
                sqlWhere += string.Format(@" and (T3.code like '%{0}%' or T3.name like '%{0}%' or T3.specification like '%{0}%')", keyword);
            }
            if (!string.IsNullOrEmpty(keyword_project))
            {
                sqlWhere += string.Format(@" and t2.pubuserdefnvc6 like '%{0}%'", keyword_project);
            }

            string sql = string.Format(@"select t2.idproject, t1.id FID,T2.id FEntryID,t1.code FBillNo,t1.voucherdate FDate,T3.code FInvNumber,t3.name FInvName,t3.specification FInvStd,T4.name FUnit,       
                    CONVERT(FLOAT,t2.quantity) FQty,CONVERT(FLOAT,ISNULL(T2.pubuserdefdecm1,0)) FOutQty,CONVERT(FLOAT,t2.quantity - ISNULL(T2.pubuserdefdecm1,0))  FUnOutQty,       
                    isnull((SELECT CONVERT(FLOAT,SUM(T5.CanuseBaseQuantity)) FROM ST_CurrentStock T5 WHERE T5.idinventory=T2.idinventory and t5.idwarehouse='{1}'),0) FStockQty       
                    from Pu_PurchaseRequisition t1 join Pu_PurchaseRequisition_b t2 on t1.id=t2.idPurchaseRequisitionDTO       
                    LEFT JOIN AA_Inventory T3 ON T2.idinventory=T3.id       
                    LEFT JOIN AA_Unit T4 ON T3.idunit=T4.ID       
                    where t2.quantity - ISNULL(T2.pubuserdefdecm1,0)  > 0 AND T2.idproject='{0}' {2}", idProject, idStock, sqlWhere);

            if (noZero)
            {
                sql = string.Format(@"select * from (select t2.idproject, t1.id FID,T2.id FEntryID,t1.code FBillNo,t1.voucherdate FDate,T3.code FInvNumber,t3.name FInvName,t3.specification FInvStd,T4.name FUnit,       
                    CONVERT(FLOAT,t2.quantity) FQty,CONVERT(FLOAT,ISNULL(T2.pubuserdefdecm1,0)) FOutQty,CONVERT(FLOAT,t2.quantity - ISNULL(T2.pubuserdefdecm1,0))  FUnOutQty,       
                    isnull((SELECT CONVERT(FLOAT,SUM(T5.CanuseBaseQuantity)) FROM ST_CurrentStock T5 WHERE T5.idinventory=T2.idinventory and t5.idwarehouse='{1}'),0) FStockQty       
                    from Pu_PurchaseRequisition t1 join Pu_PurchaseRequisition_b t2 on t1.id=t2.idPurchaseRequisitionDTO       
                    LEFT JOIN AA_Inventory T3 ON T2.idinventory=T3.id       
                    LEFT JOIN AA_Unit T4 ON T3.idunit=T4.ID       
                    where t2.quantity - ISNULL(T2.pubuserdefdecm1,0)  > 0 AND T2.idproject='{0}' {2}) as t where t.FStockQty >0 ", idProject, idStock, sqlWhere);
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

    #region 
    public class Result
    {
        public string status { get; set; }
        public object data { get; set; }
        public string msg { get; set; }
    }
    #endregion

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}