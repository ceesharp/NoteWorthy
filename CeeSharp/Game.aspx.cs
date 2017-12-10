using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CeeSharp
{
    /// <summary>
    /// COMP4952 Project
    /// Author: Lancelei Herradura, Teah Elaschuk
    /// Code-behind for the Game Selection page. Passes data to the InGame page depending on which level
    /// is selected by the user.
    /// </summary>
    public partial class Game : System.Web.UI.Page
    {
        private const int INTERVAL_PREFIX = 4;      // used to cut the lbtn_ suffix from the IDs of the interval selection buttons
        private const int ARPEGGIO_SUFFIX = 12;     // used to cut the linkButton_arp_ suffix

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        /// <summary>
        /// Called when an interval level is clicked. Passes 2 pieces of information: the game type (interval), and the interval distance
        /// </summary>
        /// <param name="sender">The button pressed</param>
        /// <param name="e"></param>
        protected void IntervalSelectBtn_Click(object sender, EventArgs e)
        {
            if (sender is LinkButton)
            {
                string s = (sender as LinkButton).ID;
                Session["HiddenNav"] = "hide";
                Response.Redirect("~/InGame.aspx?GameType=interval&Dist=" + s.Substring(INTERVAL_PREFIX));
            }
        }

        /// <summary>
        /// Called when an arpeggio level is clicked. Passes 2 pieces of information: the game type (arpeggio), and the
        /// level.
        /// These buttons are disabled, and may be completed in later versions of the web app.
        /// </summary>
        /// <param name="sender">The button pressed</param>
        /// <param name="e"></param>
        protected void ArpeggioSelectBtn_Click(object sender, EventArgs e)
        {
            if (sender is LinkButton)
            {
                string s = (sender as LinkButton).ID;
                Session["HiddenNav"] = "hide";
                Response.Redirect("~/InGame.aspx?GameType=arpeggio&Level=" + s.Substring(ARPEGGIO_SUFFIX));
            }
        }
    }
}