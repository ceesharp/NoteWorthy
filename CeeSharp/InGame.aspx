<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Site.Master" CodeBehind="InGame.aspx.cs" Inherits="CeeSharp.InGame" %>
<%@ Import Namespace="CeeSharp" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .modalBackground {
            background-color: black;
            filter: alpha(opacity=90);
            opacity:0.8;
        }
        .modalPopup {
            background-color: #ffffff;
            border-width: 3px;
            border-style: solid;
            border-color: black;
            padding-top: 10px;
            padding-left: 10px;
            width: 300px;
            height: 140px;
        }
    </style>
    <script runat="server">
        private const int numStrings = 6;

        /// <summary>
        /// Number of frets on the guitar (12, plus open notes), will expand later
        /// </summary>
        private const int numFrets = 15;

        /// <summary>
        /// Maps the cells to the musical notes
        /// </summary>
        private Dictionary<TableCell, Note> notes;

        private Note previous;
        private Note selected;
        private Note target;
        private int dist;
        private static int currRound = 1;
        private static int move;
        private static int goalStep;
        private Random rand;


        /// <summary>
        /// Gets the game level info passed via query strings from the game selection page,
        /// or goes back if the values are not defined.
        /// Initializes the fretboard
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void Page_Load(object sender, EventArgs e)
        {

            // no level information, go back
            if (Request.QueryString["GameType"] == null
                || Request.QueryString["Dist"] == null)
            {
                Response.Redirect("~/Game.aspx");
            }

            // extract the level information and display it at the top of the page
            Label_title.Text = "<h1>"
                + Request.QueryString["GameType"].ToString()
                + ": " + Request.QueryString["Dist"].ToString()
                + "</h1>";

            // init UI
            InitFretboard();
            InitValues();
            SetTooltips();
            SetStringLabels();

            rand = new Random();
            Panel1.Visible = false;
            Int32.TryParse(Request.QueryString["Dist"], out dist);

            if (!IsPostBack)
            {
                selected = previous = NotesProvider.F;
                SetUpTurn();
                currRound = 1;
                newGame();
            }
            else
            {
                previous = NotesProvider.GetNoteByName(Label_previous.Text);
                target = NotesProvider.GetNoteByName(Label_target.Text);
            }

        }

        protected void newGame()
        {
            move = 0;
            goalStep = rand.Next(7,13);
            Label_completed.Text = move + " / " + goalStep;
            Label_move.Text = move.ToString();

        }

        /// <summary>
        /// Creates a mock guitar fretboard using table, tablerow, and tablecell controls.
        /// </summary>
        protected void InitFretboard()
        {
            Table_fretboard.Width = new Unit("100%");
            // for each string on the fretboard, create a table row
            for (int i = 0; i < 6; i++)
            {
                Table_fretboard.Rows.Add(new TableRow());
                for (int j = 0; j < numFrets; j++)     // for each fret per string, create a note and assign a css class
                {
                    Table_fretboard.Rows[i].Cells.Add(new TableCell() { CssClass = "cell" });
                    LinkButton lb = new LinkButton
                    {
                        //ImageUrl = "~/Icons/bigstring.png",
                        Width = new Unit("100%"),
                        Text = "#",
                        CausesValidation = false
                    };
                    lb.Click += LinkButton_Click;

                    Table_fretboard.Rows[i].Cells[j].Controls.Add(lb);

                }
            }
        }

        /// <summary>
        /// Sets values for each note
        /// </summary>
        protected void InitValues()
        {
            notes = new Dictionary<TableCell, Note>();
            int k;
            for(int i = 0; i < numStrings; i++)
            {
                switch(i)
                {
                    case 1:
                        k = 2;      // index of note B
                        break;
                    case 2:
                        k = 10;     // index of note G
                        break;
                    case 3:
                        k = 5;      // index of note D
                        break;
                    case 4:
                        k = 0;      // index of note A
                        break;
                    default:
                        k = 7;      // index of notes E and e
                        break;
                }
                for(int j = 0; j < numFrets; j++)
                {
                    if (k == 12)        // if the index goes out of bounds, go back to the beginning
                        k = 0;
                    notes.Add(Table_fretboard.Rows[i].Cells[j], NotesProvider.Notes[k++]);
                }
            }
        }

        /// <summary>
        /// Sets hover tags for the notes
        /// </summary>
        protected void SetTooltips()
        {
            for(int i = 0; i < numStrings; i++)
            {
                for(int j = 1; j < numFrets; j++)
                {
                    Table_fretboard.Rows[i].Cells[j].ToolTip = notes[Table_fretboard.Rows[i].Cells[j]].Name;
                }
            }
        }

        /// <summary>
        /// Sets the string names in the first column (open notes)
        /// </summary>
        protected void SetStringLabels()
        {
            for(int i = 0; i < numStrings; i++)
            {
                Control c = Table_fretboard.Rows[i].Cells[0].Controls[0];
                if (c is LinkButton)
                {
                    (c as LinkButton).Text = (c as LinkButton).Text = notes[Table_fretboard.Rows[i].Cells[0]].Name;
                    (c as LinkButton).Style.Add("color", "black");
                }
            }
        }

        private void LinkButton_Click(Object sender, EventArgs e)
        {
            if (sender is LinkButton) {
                Control p = (sender as LinkButton).Parent;
                if (p is TableCell)
                {
                    selected = notes[(p as TableCell)];


                    if (ValidateMove())
                    {

                        move++;
                        Label_stat.Text = "GOOD";
                        if(move < goalStep)
                            SetUpTurn();
                        else
                            showModal();
                    } else
                    {
                        Label_stat.Text = "NO GOOD";
                    }
                }
            }
        }

        private void SetUpTurn()
        {
            previous = selected;
            target = NotesProvider.GetTarget(previous, dist);
            System.Diagnostics.Debug.WriteLine("in setupturn: " + target.Name);
            Label_previous.Text = previous.Name;
            Label_target.Text = target.Name;
            Label_completed.Text = move + " / " + goalStep;
            Label_move.Text = move.ToString();
        }

        private bool ValidateMove()
        {
            if (target.Name == selected.Name)
                return true;
            return false;

        }

        protected void showModal()
        {
            Panel1.Visible = true;
            stats.Visible = false;
            if(currRound < 5)
            {
                modalMessage.Text = "You finished round " + currRound;

            } else
            {
                modalMessage.Text = "You finished the level! ";
                OK.Text = "Finish";
            }

            ModalPopupExtender1.Show();
        }

        protected void TestBtn_Click(object sender, EventArgs e)
        {
            stats.Visible = false;
            if(currRound < 5)
            {
                modalMessage.Text = "You finished round " + currRound;

            } else
            {
                modalMessage.Text = "You finished the level! ";
                OK.Text = "Finish";
            }

            ModalPopupExtender1.Show();

        }

        protected void OK_Click(object sender, EventArgs e)
        {
            ModalPopupExtender1.Hide();
            stats.Visible = true;

            // Check and add achievements hurr
            if (currRound.Equals(5))
                Response.Redirect("~/Game");
            else
                newGame();
            currRound++;
        }

    </script>
    
    <!--
        COMP4952 Project
        Author: Teah Elaschuk

        InGame page: Work in progress
        displays the game type and level at the moment
        Update: Lancelei Herradura  Change: Added updatepanel
    -->
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="container text-center">
                <asp:Label ID="Label_title" runat="server" Text=""></asp:Label>
                <br /><br />
                <div class="background">
                    <asp:Table ID="Table_fretboard" class="fretboard" runat="server" >     
                    </asp:Table>
                </div>
                <br />
                <br />
                <div class="container">
                    <div class="row">
                        <div class="col-sm-9 col-md-6 col-lg-8">
                            <asp:Label ID="Label_goal" runat="server" Text="Complete the level by moving around the freboard using the interval."></asp:Label>
                        </div>
                        <div id="stats" runat="server" class="col-sm-3 col-md-6 col-lg-4">
                                <asp:Label ID="Label_tprevious" runat="server" Text="Current Note: " ></asp:Label>
                                <asp:Label ID="Label_previous" runat="server" Text=""></asp:Label>
                                <br />
                                <asp:Label ID="Label_ttarget" runat="server" Text="Target: "></asp:Label>
                                <asp:Label ID="Label_target" runat="server" Text=""></asp:Label>
                                <br />
                                <asp:Label ID="Label_tcompleted" runat="server" Text="Moves Completed: "></asp:Label>
                                <asp:Label ID="Label_completed" runat="server" Text=""></asp:Label>
                                <br />
                                <asp:Label ID="Label_tmove" runat="server" Text="Current Move: "></asp:Label>
                                <asp:Label ID="Label_move" runat="server" Text=""></asp:Label>
                                <br />
                                <asp:Label ID="Label_stat" runat="server" Text=""></asp:Label>
                            </div>
                        </div>
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <asp:Panel ID="Panel1" runat="server" CssClass="modalPopup">
                            <h4>Congratulations!</h4>
                            <asp:Label ID="modalMessage" runat="server" Text="You finished this round!"></asp:Label>
                            <br />
                            <!-- Test to go to next round -->
                            <asp:Button ID="OK" runat="server" class="btn btn-primary" Text="Go to Next Round" OnClick="OK_Click"   />
                            <asp:HiddenField ID="hdnField" runat="server" />
                        </asp:Panel>
                        <ajaxToolkit:ModalPopupExtender ID="ModalPopupExtender1" runat="server" BackgroundCssClass="modalBackground" PopupControlID="Panel1" TargetControlID="hdnField">

                        </ajaxToolkit:ModalPopupExtender>
                    </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    <asp:Button runat="server" Text="Update" onClick="UpdateAchievement" />
</asp:Content>

