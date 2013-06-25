<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="pxi:test-report" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc-internal/xprocspec"
    exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test"
    xmlns:html="http://www.w3.org/1999/xhtml">

    <p:documentation>Makes the machine-readable reports human-readable.</p:documentation>

    <p:input port="source" sequence="true"/>
    <p:output port="result" primary="true" sequence="true">
        <p:pipe port="result" step="result"/>
    </p:output>
    <p:output port="junit">
        <p:pipe port="result" step="junit"/>
    </p:output>
    <p:output port="html">
        <p:pipe port="result" step="html"/>
    </p:output>
    
    <p:import href="../utils/logging-library.xpl"/>

    <p:insert match="/html:html/html:body/html:div" position="last-child">
        <p:input port="source">
            <p:inline exclude-inline-prefixes="#all">
                <html xmlns="http://www.w3.org/1999/xhtml">
                    <head>
                        <meta charset="utf-8" />
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
    <p:viewport match="c:error/*">
        <p:escape-markup/>
    </p:viewport>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="report-to-html.xsl"/>
        </p:input>
    </p:xslt>
    <p:identity name="html"/>
    
    <p:wrap-sequence wrapper="x:test-report">
        <!-- TODO: decide on a main format for machine-readable reports -->
        <p:input port="source">
            <p:pipe port="source" step="main"/>
        </p:input>
    </p:wrap-sequence>
    
    <!-- validate output grammar -->
    <p:for-each>
        <p:identity name="try.input"/>
        <p:try>
            <p:group>
                <p:validate-with-relax-ng>
                    <p:input port="schema">
                        <p:document href="../../schema/xprocspec.results.rng"/>
                    </p:input>
                </p:validate-with-relax-ng>
                <p:wrap-sequence wrapper="calabash-issue-102"/>
            </p:group>
            <p:catch name="catch">
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="error" step="catch"/>
                    </p:input>
                </p:identity>
                <p:add-attribute match="/*" attribute-name="error-location" attribute-value="report.xpl - validation of output grammar"/>
                
                <p:identity name="errors-without-was"/>
                <p:wrap-sequence wrapper="x:was">
                    <p:input port="source">
                        <p:pipe port="result" step="try.input"/>
                    </p:input>
                </p:wrap-sequence>
                <p:add-attribute match="/*" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="base-uri(/*/*)"/>
                </p:add-attribute>
                <p:wrap-sequence wrapper="c:error"/>
                <p:add-attribute match="/*" attribute-name="type" attribute-value="was"/>
                <p:identity name="was"/>
                <p:insert match="/*" position="last-child">
                    <p:input port="source">
                        <p:pipe port="result" step="errors-without-was"/>
                    </p:input>
                    <p:input port="insertion">
                        <p:pipe port="result" step="was"/>
                    </p:input>
                </p:insert>
                
                <p:wrap-sequence wrapper="x:test-report"/>
                <p:wrap-sequence wrapper="calabash-issue-102"/>
            </p:catch>
        </p:try>
        <p:for-each>
            <!-- temporary fix for https://github.com/ndw/xmlcalabash1/issues/102 -->
            <p:iteration-source select="/calabash-issue-102/*"/>
            <p:identity/>
        </p:for-each>
    </p:for-each>
    <p:identity name="result"/>

    <p:for-each>
        <p:iteration-source>
            <p:pipe port="source" step="main"/>
        </p:iteration-source>
        <p:viewport match="c:was|c:expected">
            <p:escape-markup/>
        </p:viewport>
        <p:xslt>
            <p:input port="source"> </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="report-to-junit.xsl"/>
            </p:input>
        </p:xslt>
    </p:for-each>
    <p:wrap-sequence wrapper="testsuites"/>
    <p:add-attribute match="/*" attribute-name="disabled" attribute-value="'false'"/>
    <p:add-attribute match="/*" attribute-name="errors">
        <p:with-option name="attribute-value" select="sum(/*/*/@errors)"/>
    </p:add-attribute>
    <p:add-attribute match="/*" attribute-name="failures">
        <p:with-option name="attribute-value" select="sum(/*/*/@failures)"/>
    </p:add-attribute>
    <!--<p:add-attribute match="/*" attribute-name="name" attribute-value="'TODO'"/>-->
    <p:add-attribute match="/*" attribute-name="tests">
        <p:with-option name="attribute-value" select="sum(/*/*/@tests)"/>
    </p:add-attribute>
    <p:add-attribute match="/*" attribute-name="time">
        <p:with-option name="attribute-value" select="sum(/*/*/@time)"/>
    </p:add-attribute>
    <p:identity name="junit"/>

</p:declare-step>
