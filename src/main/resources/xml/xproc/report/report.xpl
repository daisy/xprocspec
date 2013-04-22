<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="px:test-report" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" pkg:import-uri="http://josteinaj.no/ns/2013/xprocspec/report.xpl" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test"
    xmlns:html="http://www.w3.org/1999/xhtml">

    <p:documentation>Makes the machine-readable reports human-readable.</p:documentation>

    <p:input port="source" sequence="true"/>
    <p:output port="result" primary="true"/>
    <p:output port="html"/>

    <p:insert match="/html:html/html:body/html:div" position="last-child">
        <p:input port="source">
            <p:inline exclude-inline-prefixes="#all">
                <html xmlns="http://www.w3.org/1999/xhtml">
                    <head>
                        <title>Test Results</title>
                        <style type="text/css" xml:space="preserve"> 
                            body { 
                            font-family: helvetica; 
                            } 
                            pre.box { 
                            white-space: pre-wrap; /* css-3 */ 
                            white-space: -moz-pre-wrap; /*Mozilla, since 1999 */ 
                            white-space: -pre-wrap; /* Opera 4-6 */
                            white-space: -o-pre-wrap; /* Opera 7 */ 
                            word-wrap: break-word; /*Internet Explorer 5.5+ */ 
                            } 
                            li.error div { 
                            display: table; 
                            border: gray thin solid; 
                            padding: 5px; 
                            } 
                            li.error div h3 { 
                            display: table-cell; 
                            padding-right: 10px; 
                            font-size: smaller; 
                            } 
                            li.error div pre.box { 
                            display: table-cell; 
                            } 
                            li { 
                            padding-bottom: 15px; 
                            } 
                            #toc {
                            border-spacing: 0px;
                            }
                            #toc th, #toc td {
                            padding: 5px 30px 5px 10px;
                            border-spacing: 0px;
                            font-size: 90%;
                            margin: 0px;
                            }
                            #toc th, #toc td {
                            text-align: left;
                            border-top: 1px solid #f1f8fe;
                            border-bottom: 1px solid #cbd2d8;
                            border-right: 1px solid #cbd2d8;
                            }
                            
                            #toc tr:nth-child(odd) {
                            background-color: #e0e9f0;
                            }
                            #toc tr:nth-child(even), #toc thead th {
                            background-color: #e8eff5; !important;
                            }
                            
                        </style>
                    </head>
                    <body>
                        <div class="container">
                            <div class="page-header">
                                <h1>Test Results</h1>
                            </div>
                        </div>
                    </body>
                </html>
            </p:inline>
        </p:input>
        <p:input port="insertion">
            <p:pipe port="source" step="main"/>
        </p:input>
    </p:insert>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="report-to-html.xsl"/>
        </p:input>
    </p:xslt>

</p:declare-step>
