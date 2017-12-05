using App.Extensions;
using CeeSharp.Models;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Providers.Entities;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CeeSharp
{
    /// <summary>
    /// COMP4952 Project
    /// Author: Teah Elaschuk
    /// Code behind for InGame page: Work in progress
    /// Modified By:
    /// Name: Lancelei Herradura    Change: Moved functions to aspx     Date: 2017-11-30
    /// 
    /// Clicking on a fret will display the selected note.
    /// </summary>
    public partial class InGame : System.Web.UI.Page
    {
        /// <summary>
        /// Author: Ebon
        /// Modified By:
        /// Name: Ebon    Change: regex expression     Date: 2017-12-03
        ///               Change: update claim         Date: 2017-12-04
        /// 
        /// Update uer's Achievement data
        ///     Insert the new data if the data doesn't exist.
        /// </summary>
        protected void UpdateAchievement(object sender, EventArgs e)
        {
            if (Context.User.Identity.GetUserName() != null && Context.User.Identity.IsAuthenticated)
            {
                var manager = Context.GetOwinContext().GetUserManager<ApplicationUserManager>();
                var user = manager.FindByName(Context.User.Identity.Name);

                if (Regex.Match(user.Achievement, @"," + Request.QueryString["Dist"].ToString() + ",").Value != ("," + Request.QueryString["Dist"].ToString() + ","))
                {
                    user.Achievement += Request.QueryString["Dist"].ToString() + ",";
                    manager.Update(user);
                    Context.User.Identity.UpdateClaim("Achievement", user.Achievement);
                }

            }
        }
    }    
        
    
}