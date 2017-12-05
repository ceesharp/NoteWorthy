<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Site.Master" CodeBehind="Achievements.aspx.cs" Inherits="CeeSharp.Achievements" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- This is for the cool tooltip effect -->
    <script>
        $(document).ready(function () {
            $('[data-toggle="popover"]').popover();
        });
</script>
    <div class="row">
            <div>
                <div class="row">
                    <div class="col-xs-6" style="left: 0px; top: 0px; width: 34%" >
                        <asp:Image ID="ProfilePic" CssClass="pull-right" runat="server" Height="110px" ImageUrl="~/Icons/003-profile.png" />
                    </div>
                    <div class="col-xs-6">
                        <asp:Label ID="Label1" runat="server" style="font-size: medium" Text="Your Achievements"></asp:Label>
                        <br />
                        <br />
                        <br />
                        <ul ID="imgList" runat="server">
                            <%--<li><img title="Sampler Plate" data-placement="top" data-toggle="popover" data-trigger="hover" data-content="Finished Interval level with no error" runat="server" id="img1" src="Icons/002-success.png" height="75" /></li>
                            <li><img data-placement="top" data-toggle="popover" data-trigger="hover" title="Sampler Plate Advanced" data-content="Finished Arpeggios level with no error" runat="server" id="img2" src="Icons/002-success.png" height="75" /></li>
                            <li><img data-placement="top" data-toggle="popover" data-trigger="hover" title="Trooper" data-content="Complete a tutorial lesson" runat="server" id="img3" src="Icons/002-success.png" height="75" /></li>
                            <li><img data-placement="top" data-toggle="popover" data-trigger="hover" title="Rising Star" data-content="Logged in more than 10 times" runat="server" id="img4" src="Icons/002-success.png" height="75" /></li>
                            <li><img data-placement="top" data-toggle="popover" data-trigger="hover" title="Young Star" data-content="Registered (Get Started)" runat="server" id="img5" src="Icons/002-success.png" height="75" /></li>
                            <li><img data-placement="top" data-toggle="popover" data-trigger="hover" title="Rocking" data-content="Finished Interval level with no error under 5 minutes" runat="server" id="img6" src="Icons/002-success.png" height="75" /></li>
                            <li><img data-placement="top" data-toggle="popover" data-trigger="hover" title="Headbanging" data-content="Finished Arpeggios level with no error under 5 minutes" runat="server" id="img7" src="Icons/002-success.png" height="75" /></li>
                            <li><img data-placement="top" data-toggle="popover" data-trigger="hover" title="Calloused Fingers" data-content="Finished an entire Interval course in one session" runat="server" id="img8" src="Icons/002-success.png" height="75" /></li>
                            <li><img data-placement="top" data-toggle="popover" data-trigger="hover" title="Metal Fingers" data-content="Finished an entire Arpeggios course in one session" runat="server" id="img9" src="Icons/002-success.png" height="75" /></li>
                            <li><img data-placement="top" data-toggle="popover" data-trigger="hover" title="Shooting Star" data-content="Finished an entire Interval course in one session with no error" runat="server" id="img10" src="Icons/002-success.png" height="75" /></li>
                            <li><img data-placement="top" data-toggle="popover" data-trigger="hover" title="Super Star" data-content="Finished an entire Arpeggios course in one session with no error" runat="server" id="img11" src="Icons/002-success.png" height="75" /></li>--%>
                        </ul>

                    </div>
                </div>
                
            </div>
        </div>
</asp:Content>
