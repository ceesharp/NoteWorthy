using System;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Web;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;
using Microsoft.AspNet.Identity.Owin;
using Microsoft.Owin.Security;
using CeeSharp.Models;
using System.Security.Principal;

namespace CeeSharp.Models
{
    // You can add User data for the user by adding more properties to your User class, please visit http://go.microsoft.com/fwlink/?LinkID=317594 to learn more.
    public class ApplicationUser : IdentityUser
    {
        // Add Custom Columns
        public string Achievement { get; set; }
        public string Profile_Picture { get; set; }
        public string NickName { get; set; }
        public ClaimsIdentity GenerateUserIdentity(ApplicationUserManager manager)
        {
            // Note the authenticationType must match the one defined in CookieAuthenticationOptions.AuthenticationType
            var userIdentity = manager.CreateIdentity(this, DefaultAuthenticationTypes.ApplicationCookie);

            // Add Claim for retrieving specific data members
            userIdentity.AddClaim(new Claim("Achievement", this.Achievement.ToString()));
            userIdentity.AddClaim(new Claim("Profile_Picture", this.Profile_Picture.ToString()));
            userIdentity.AddClaim(new Claim("NickName", this.NickName.ToString()));

            // Add custom user claims here
            return userIdentity;
        }

        public Task<ClaimsIdentity> GenerateUserIdentityAsync(ApplicationUserManager manager)
        {
            return Task.FromResult(GenerateUserIdentity(manager));
        }
    }

    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext()
            : base("DefaultConnection", throwIfV1Schema: false)
        {
        }

        public static ApplicationDbContext Create()
        {
            return new ApplicationDbContext();
        }
    }
}

namespace App.Extensions
{
    public static class IdentityExtensions
    {
        /// <summary>
        /// Return Achievement
        /// </summary>
        /// <param name="identity">User Identity</param>
        /// <returns></returns>
        public static string GetAchievement(this IIdentity identity)
        {
            var claim = ((ClaimsIdentity)identity).FindFirst("Achievement");
            // Test for null to avoid issues during local testing
            return (claim != null) ? claim.Value : string.Empty;
        }

        /// <summary>
        /// Return Profile_Picture
        /// </summary>
        /// <param name="identity">User Identity</param>
        /// <returns></returns>
        public static string GetProfile_Picture(this IIdentity identity)
        {
            var claim = ((ClaimsIdentity)identity).FindFirst("Profile_Picture");
            return (claim != null) ? claim.Value : string.Empty;
        }

        /// <summary>
        /// Return NickName
        /// </summary>
        /// <param name="identity">User Identity</param>
        /// <returns></returns>
        public static string GetNickName(this IIdentity identity)
        {
            var claim = ((ClaimsIdentity)identity).FindFirst("NickName");
            return (claim != null) ? claim.Value : string.Empty;
        }


        public static void UpdateClaim(this IIdentity identity, string key, string value)
        {
            if (((ClaimsIdentity)identity) == null)
                return;

            // Check for existing claim and remove it
            var claim = ((ClaimsIdentity)identity).FindFirst(key);
            if (claim != null)
                ((ClaimsIdentity)identity).RemoveClaim(claim);

            // Add the new claim
            ((ClaimsIdentity)identity).AddClaim(new Claim(key, value));
            var authenticationManager = HttpContext.Current.GetOwinContext().Authentication;
            authenticationManager.AuthenticationResponseGrant = new AuthenticationResponseGrant(new ClaimsIdentity(identity), new AuthenticationProperties() { IsPersistent = true });
        }
    }
}

#region Helpers
namespace CeeSharp
{
    public static class IdentityHelper
    {
        // Used for XSRF when linking external logins
        public const string XsrfKey = "XsrfId";

        public const string ProviderNameKey = "providerName";
        public static string GetProviderNameFromRequest(HttpRequest request)
        {
            return request.QueryString[ProviderNameKey];
        }

        public const string CodeKey = "code";
        public static string GetCodeFromRequest(HttpRequest request)
        {
            return request.QueryString[CodeKey];
        }

        public const string UserIdKey = "userId";
        public static string GetUserIdFromRequest(HttpRequest request)
        {
            return HttpUtility.UrlDecode(request.QueryString[UserIdKey]);
        }

        public static string GetResetPasswordRedirectUrl(string code, HttpRequest request)
        {
            var absoluteUri = "/Account/ResetPassword?" + CodeKey + "=" + HttpUtility.UrlEncode(code);
            return new Uri(request.Url, absoluteUri).AbsoluteUri.ToString();
        }

        public static string GetUserConfirmationRedirectUrl(string code, string userId, HttpRequest request)
        {
            var absoluteUri = "/Account/Confirm?" + CodeKey + "=" + HttpUtility.UrlEncode(code) + "&" + UserIdKey + "=" + HttpUtility.UrlEncode(userId);
            return new Uri(request.Url, absoluteUri).AbsoluteUri.ToString();
        }

        private static bool IsLocalUrl(string url)
        {
            return !string.IsNullOrEmpty(url) && ((url[0] == '/' && (url.Length == 1 || (url[1] != '/' && url[1] != '\\'))) || (url.Length > 1 && url[0] == '~' && url[1] == '/'));
        }

        public static void RedirectToReturnUrl(string returnUrl, HttpResponse response)
        {
            if (!String.IsNullOrEmpty(returnUrl) && IsLocalUrl(returnUrl))
            {
                response.Redirect(returnUrl);
            }
            else
            {
                response.Redirect("~/");
            }
        }
    }
}
#endregion
