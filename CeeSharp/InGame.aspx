<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Site.Master" CodeBehind="InGame.aspx.cs" Inherits="CeeSharp.InGame" %>

<%@ Import Namespace="CeeSharp" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    
    <!--
        InGame page
        This file contains the client-side and server-side code for the in-game page.
    -->
    <script runat="server">

        /// <summary>
        /// Number of strings on the guitar
        /// </summary>
        private const int numStrings = 6;

        /// <summary>
        /// Number of frets on the guitar (14, plus open notes)
        /// </summary>
        private const int numFrets = 15;

        /// <summary>
        /// Maps the cells to the musical notes
        /// </summary>
        private Dictionary<TableCell, Note> notes;

        private Note previous;              // the last correct note, and current interval base
        private Note selected;              // the note that the user selects - may or may not be correct
        private Note target;                // the next interval from the previous note. this is considered the correct answer
        private int dist;                   // the distance in semitones unique to the game level (can be 1 to 12)
        private static int currRound = 1;   // the initial value for the number of rounds. A game has 5 rounds.
        private static int move;            // the current move for the round. reaching the goalStep completes a round.
        private static int goalStep;        // the number of moves required to complete a round
        private Random rand;                // a random object used to find the starting note and goalstep

        /// <summary>
        /// List of all the formal level names.
        /// </summary>
        private static String[] LevelNames = {"Minor Seconds", "Major Seconds", "Minor Thirds",
            "Major Thirds", "Perfect Fourths", "Minor Fifths", "Perfect Fifths", "Minor Sixths",
            "Major Sixths", "Minor Sevenths", "Major Sevenths", "Octaves"};

        /// <summary>
        ///  Stores the formal level name.
        /// </summary>
        private string LevelName;

        /// <summary>
        /// Author: Teah Elaschuk
        /// 
        /// Gets the game level info passed via query strings from the game selection page,
        /// or goes back if the values are not defined.
        /// Initializes the fretboard, sets up the game, and begins the first round.
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
            LevelName = LevelNames[Convert.ToInt32(Request.QueryString["Dist"]) - 1];
            // extract the level information and display it at the top of the page
            Label_title.Text = "<h1>" + LevelName + "</h1>";

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
                currRound = 1;
                newGame();
            }
            else
            {
                previous = NotesProvider.GetNoteByName(Label_previous.Text);
                target = NotesProvider.GetNoteByName(Label_target.Text);
            }

        }

        /// <summary>
        /// Author: Lancelei Herradura
        /// 
        /// Sets up a new game after a round is completed. 
        /// Modified By:
        /// Name: Teah    Change: made game more difficult after the 2nd round, found number of moves per round
        /// </summary>
        protected void newGame()
        {
            // reset selected frets
            foreach (TableRow r in Table_fretboard.Rows)
                foreach(TableCell c in r.Cells)
                    c.CssClass = "cell";

            // get starting point
            int startFret = rand.Next(numFrets);
            int startString = rand.Next(2)+4;           // best to start on the 5th and 6th strings (A and E)
            Table_fretboard.Rows[startString].Cells[startFret].CssClass = "selected";
            selected = previous = notes[Table_fretboard.Rows[startString].Cells[startFret]];

            // after a certain point in the game, make the rounds more difficult
            if(currRound == 3)
            {
                SetUpHints();
            }
            
            // logic for finding a reasonable number of steps for the starting point
            move = 0;
            goalStep = Convert.ToInt32((startString*numFrets + numFrets - startFret) / dist); // all remaining frets divided by the distance
            if (goalStep > 40)
                goalStep = rand.Next(6, 12);
            else if (goalStep > 12)
                goalStep = rand.Next(5, 8);
            
            Label_completed.Text = move + " / " + goalStep;

            SetUpTurn();
        }

        /// <summary>
        /// Author: Teah Elaschuk
        /// 
        /// Disables the target display and displays a hint instead, making the game more difficult.
        /// </summary>
        private void SetUpHints()
        {
            // hide the target message
            Label_target.Visible = false;
            Label_ttarget.Visible = false;

            // change goal message
            Label_goal.Text = "Hint: The distance between " + LevelName + " is " 
                + dist + " semitones.";
        }

        /// <summary>
        /// Author: Teah Elaschuk
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
        /// Author: Teah Elaschuk
        /// Sets values for each note
        /// </summary>
        protected void InitValues()
        {
            notes = new Dictionary<TableCell, Note>();
            int k;
            for (int i = 0; i < numStrings; i++)
            {
                switch (i)
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
                for (int j = 0; j < numFrets; j++)
                {
                    if (k == 12)        // if the index goes out of bounds, go back to the beginning
                        k = 0;
                    notes.Add(Table_fretboard.Rows[i].Cells[j], NotesProvider.Notes[k++]);
                }
            }
        }

        /// <summary>
        /// Author: Teah Elaschuk
        /// Sets hover tags for the notes
        /// </summary>
        protected void SetTooltips()
        {
            for (int i = 0; i < numStrings; i++)
            {
                for (int j = 1; j < numFrets; j++)
                {
                    Table_fretboard.Rows[i].Cells[j].ToolTip = notes[Table_fretboard.Rows[i].Cells[j]].Name;
                }
            }
        }

        /// <summary>
        /// Author: Teah Elaschuk
        /// Sets the string names in the first column (open notes)
        /// </summary>
        protected void SetStringLabels()
        {
            for (int i = 0; i < numStrings; i++)
            {
                Control c = Table_fretboard.Rows[i].Cells[0].Controls[0];
                if (c is LinkButton)
                {
                    (c as LinkButton).Text = (c as LinkButton).Text = notes[Table_fretboard.Rows[i].Cells[0]].Name;
                    (c as LinkButton).Style.Add("color", "black");
                }
            }
        }

        /// <summary>
        /// Author: Teah Elaschuk
        /// When a note on the fretboard is selected, the user's choice is recorded and validated.
        /// If the answer is correct, the next round is set up
        /// 
        /// Modified By:
        /// Name: Lancelei    Change: ends the round if all moves are completed and sets up another turn otherwise
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void LinkButton_Click(Object sender, EventArgs e)
        {
            if (sender is LinkButton)
            {
                Control p = (sender as LinkButton).Parent;
                if (p is TableCell)
                {
                    selected = notes[(p as TableCell)];

                    if (ValidateMove())
                    {
                        (p as TableCell).CssClass = "selected";
                        move++;
                        if (move < goalStep)
                            SetUpTurn();
                        else
                            showModal();
                    }
                }
            }
        }

        /// <summary>
        /// Author: Teah Elaschuk, Lancelei Herradura
        /// Before a user can select a note, the fretboard must find the next target and update the data. 
        /// </summary>
        private void SetUpTurn()
        {
            previous = selected;
            target = NotesProvider.GetTarget(previous, dist);
            Label_previous.Text = previous.Name;
            Label_target.Text = target.Name;
            Label_completed.Text = move + " / " + goalStep;
        }

        /// <summary>
        /// Author: Teah Elaschuk
        /// 
        /// Checks if the user's selection was correct.
        /// </summary>
        /// <returns></returns>
        private bool ValidateMove()
        {
            if (target.Name == selected.Name)
                return true;
            return false;

        }

        /// <summary>
        /// Author: Lancelei Herradura
        /// 
        /// </summary>
        protected void showModal()
        {
            Panel1.Visible = true;
            stats.Visible = false;
            if (currRound < 5)
            {
                modalMessage.Text = "You finished round " + currRound + "!";
                if (currRound == 2)
                    modalMessage.Text +=  " This time, start thinking about the distances between intervals.";
                if (currRound == 3)
                    modalMessage.Text +=  " Now, try and determine the target yourself.";

            }
            else
            {
                modalMessage.Text = "You finished the level! ";
                OK.Text = "Finish";
            }

            ModalPopupExtender1.Show();
        }

        protected void TestBtn_Click(object sender, EventArgs e)
        {
            //stats.Visible = false;
            //if (currRound < 5)
            //{
            //    modalMessage.Text = "You finished round " + currRound;

            //}
            //else
            //{
            //    modalMessage.Text = "You finished the level! ";
            //    OK.Text = "Finish";
            //}

            //ModalPopupExtender1.Show();
            showModal();

        }

        /// <summary>
        /// Author: Lancelei Herradura
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void OK_Click(object sender, EventArgs e)
        {
            ModalPopupExtender1.Hide();
            stats.Visible = true;

            // Check and add achievements hurr
            if (currRound.Equals(5))
            {
                // Insert this achievement into User data if it's logged in
                if (Context.User.Identity.GetUserName() != null && Context.User.Identity.IsAuthenticated)
                    UpdateAchievement(sender, e);
                Response.Redirect("~/Game");
            }
            else
                newGame();
            currRound++;
        }

    </script>

    <!--
        Displays the game level, the fretboard, and a panel with game information.
        Modified By: Lancelei Herradura  Change: Added updatepanel
    -->
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="container text-center">
                <asp:Label ID="Label_title" runat="server" Text=""></asp:Label>
                <br />
                <br />
                <div class="background">
                    <asp:Table ID="Table_fretboard" class="fretboard" runat="server">
                    </asp:Table>
                </div>
                <br />
                <br />
                <div class="container game-labels">
                    <div class="row">
                        <div class="col-sm-9 col-md-6 col-lg-8 message">
                            <asp:Label ID="Label_goal" runat="server" Text="Complete the level by moving around the freboard using the interval."></asp:Label>
                        </div>
                        <div id="stats" runat="server" class="col-sm-3 col-md-6 col-lg-4">
                            <div class="stats-feature">    
                                <asp:Label ID="Label_tcompleted" runat="server" Text="Moves Completed: "></asp:Label>
                                <asp:Label ID="Label_completed" runat="server" Text=""></asp:Label>
                            </div>
                            <br />
                            <div class="stats">    
                                <asp:Label ID="Label_tprevious" runat="server" Text="Current Note: "></asp:Label>
                                <asp:Label ID="Label_previous" runat="server" Text=""></asp:Label>
                                    <br />
                                <asp:Label ID="Label_ttarget" runat="server" Text="Target: "></asp:Label>
                                <asp:Label ID="Label_target" runat="server" Text=""></asp:Label>
                            </div>
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
                        <asp:Button ID="OK" runat="server" class="btn btn-primary" Text="Go to Next Round" OnClick="OK_Click" />
                        <asp:HiddenField ID="hdnField" runat="server" />
                    </asp:Panel>
                    <ajaxToolkit:ModalPopupExtender ID="ModalPopupExtender1" runat="server" BackgroundCssClass="modalBackground" PopupControlID="Panel1" TargetControlID="hdnField">
                    </ajaxToolkit:ModalPopupExtender>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

