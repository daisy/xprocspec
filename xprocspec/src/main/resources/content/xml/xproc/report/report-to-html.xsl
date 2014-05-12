<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" xmlns:x="http://www.daisy.org/ns/xprocspec" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <xsl:template match="html">
        <xsl:variable name="descriptions" select="body/x:description[not(x:scenario/@pending)]"/>
        <xsl:variable name="pending-descriptions" select="body/x:description[x:scenario/@pending]"/>
        <xsl:variable name="errors" select="body/c:errors"/>
        <xsl:variable name="test-base-uri" select="string((body/*/@test-base-uri)[1])"/>
        <xsl:variable name="tests" select="$descriptions/x:test-result"/>
        <xsl:variable name="scripts" select="distinct-values($descriptions/@script)"/>
        <xsl:variable name="scripts-short" select="for $uri in ($scripts) return replace($uri,'^.*/','')"/>
        <xsl:variable name="passed" select="count($tests[@result='passed'])"/>
        <xsl:variable name="pending" select="count($tests[@result='skipped'] | $pending-descriptions)"/>
        <xsl:variable name="failed" select="count($tests[@result='failed'])"/>
        <xsl:variable name="error-count" select="count($errors)"/>
        <xsl:variable name="total" select="count($tests) + count($pending-descriptions) + $error-count"/>
        <xsl:variable name="log" select="body/c:log"/>

        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="head">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <title>Test Report for <xsl:value-of select="$test-base-uri"/> (passed:<xsl:value-of select="$passed"/> / pending:<xsl:value-of select="$pending"/> / failed:<xsl:value-of
                            select="$failed"/> / errors:<xsl:value-of select="$error-count"/> / total:<xsl:value-of select="$total"/>)</title>
                    <xsl:copy-of select="node()"/>
                    <style>
                        .pp-tag-name{
                            color:blue;
                        }
                        .pp-attr-name{
                            color:orange;
                        }
                        .pp-attr-value{
                            color:#FF4F4F;
                        }
                        .pp-document-element{
                            background-color:#F5F5F5;
                        }</style>
                </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="body">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <h1>Test Report</h1>
                    <p>Script: <a href="{$test-base-uri}"><xsl:value-of select="$test-base-uri"/></a></p>
                    <p>Tested: <xsl:value-of select="current-dateTime()"/><!-- TODO: prettier time: 10 July 2013 at 18:42 --></p>
                    <h2>Contents</h2>
                    <table>
                        <col width="75%"/>
                        <col width="5%"/>
                        <col width="5%"/>
                        <col width="5%"/>
                        <col width="5%"/>
                        <col width="5%"/>
                        <thead>
                            <tr>
                                <th/>
                                <th class="result">passed:<xsl:value-of select="$passed"/></th>
                                <th class="result">pending:<xsl:value-of select="$pending"/></th>
                                <th class="result">failed:<xsl:value-of select="$failed"/></th>
                                <th class="result">errors:<xsl:value-of select="$error-count"/></th>
                                <th class="result">total:<xsl:value-of select="$total"/></th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:if test="$errors">
                                <tr class="error label">
                                    <th>
                                        <a href="#errors">Errors</a>
                                    </th>
                                    <th class="result">0</th>
                                    <th class="result">0</th>
                                    <th class="result">0</th>
                                    <th class="result">
                                        <xsl:value-of select="$error-count"/>
                                    </th>
                                    <th class="result">
                                        <xsl:value-of select="$error-count"/>
                                    </th>
                                </tr>
                            </xsl:if>

                            <!-- for each distinct step -->
                            <xsl:for-each select="distinct-values($descriptions/x:step-declaration/*/@x:type)">
                                <xsl:variable name="type" select="."/>
                                <xsl:variable name="stepid" select="concat('step',position())"/>
                                <xsl:variable name="step-descriptions" select="$descriptions[x:step-declaration/*/@x:type=$type]"/>
                                <xsl:variable name="step-shortname" select="($step-descriptions/x:step-declaration/*/@type,$type)[1]"/>
                                <xsl:variable name="passed" select="count($step-descriptions//x:test-result[@result='passed'])"/>
                                <xsl:variable name="pending" select="count($step-descriptions//x:test-result[@result='skipped'])"/>
                                <xsl:variable name="failed" select="count($step-descriptions//x:test-result[@result='failed'])"/>
                                <xsl:variable name="total" select="count($step-descriptions//x:test-result)"/>
                                <xsl:variable name="scenario-class" select="if ($failed) then 'failed' else if ($pending) then 'pending' else if ($passed) then 'successful' else ''"/>
                                <tr class="{$scenario-class} label">
                                    <th>
                                        <a href="#{$stepid}">
                                            <xsl:value-of select="$step-shortname"/>
                                        </a>
                                    </th>
                                    <th class="result">
                                        <xsl:value-of select="$passed"/>
                                    </th>
                                    <th class="result">
                                        <xsl:value-of select="$pending"/>
                                    </th>
                                    <th class="result">
                                        <xsl:value-of select="$failed"/>
                                    </th>
                                    <th class="result">0</th>
                                    <th class="result">
                                        <xsl:value-of select="$total"/>
                                    </th>
                                </tr>
                            </xsl:for-each>

                            <xsl:for-each select="distinct-values($pending-descriptions/(x:step-declaration/*/@type,resolve-uri(@script,base-uri()))[1])">
                                <xsl:variable name="title" select="."/>
                                <xsl:variable name="pending-script-descriptions" select="$pending-descriptions[(x:step-declaration/*/@type,resolve-uri(@script,base-uri()))[1] = $title]"/>
                                <xsl:variable name="script-base" select="($pending-script-descriptions/resolve-uri(@script,base-uri()))[1]"/>
                                <tr class="pending label">
                                    <th>
                                        <a href="#pending-{count($pending-script-descriptions[1]/preceding::x:description)}">Not calling: <xsl:value-of select="$title"/></a>
                                    </th>
                                    <th class="result">0</th>
                                    <th class="result">
                                        <xsl:value-of select="count($pending-script-descriptions)"/>
                                    </th>
                                    <th class="result">0</th>
                                    <th class="result">0</th>
                                    <th class="result">
                                        <xsl:value-of select="count($pending-script-descriptions)"/>
                                    </th>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>

                    <xsl:if test="$errors">
                        <div id="errors">
                            <h2 class="error">Errors<span class="scenario-totals">passed:0 / pending:0 / failed:0 / errors:<xsl:value-of select="$error-count"/> / total:<xsl:value-of
                                        select="$error-count"/></span></h2>
                            <xsl:for-each select="$errors">
                                <xsl:call-template name="print-context"/>
                            </xsl:for-each>
                        </div>
                    </xsl:if>

                    <!-- for each distinct step -->
                    <xsl:for-each select="distinct-values($descriptions/x:step-declaration/*/@x:type)">
                        <xsl:variable name="type" select="."/>
                        <xsl:variable name="stepid" select="concat('step',position())"/>
                        <xsl:variable name="step-descriptions" select="$descriptions[x:step-declaration/*/@x:type=$type]"/>
                        <xsl:variable name="step-shortname" select="($step-descriptions/x:step-declaration/*/@type,$type)[1]"/>
                        <xsl:variable name="passed" select="count($step-descriptions/x:test-result[@result='passed'])"/>
                        <xsl:variable name="pending" select="count($step-descriptions/x:test-result[@result='skipped'])"/>
                        <xsl:variable name="failed" select="count($step-descriptions/x:test-result[@result='failed'])"/>
                        <xsl:variable name="total" select="count($step-descriptions/x:test-result)"/>
                        <xsl:variable name="step-class" select="if ($failed) then 'failed' else if ($pending) then 'pending' else if ($passed) then 'successful' else ''"/>
                        <xsl:variable name="script-base" select="($step-descriptions/resolve-uri(@script,base-uri()))[1]"/>

                        <div id="{$stepid}">
                            <h2 class="{$step-class}">Calling: <a href="{$script-base}"><xsl:value-of select="$step-shortname"/></a><span class="scenario-totals">passed:<xsl:value-of select="$passed"
                                    /> / pending:<xsl:value-of select="$pending"/> / failed:<xsl:value-of select="$failed"/> / errors:0 / total:<xsl:value-of select="$total"/></span></h2>
                            <table>
                                <col width="80%"/>
                                <col width="20%"/>
                                <tbody>
                                    <!-- for each step scenario -->
                                    <xsl:for-each select="$step-descriptions">
                                        <xsl:variable name="scenario-description" select="."/>
                                        <xsl:variable name="scenario-contexts" select="x:scenario/x:context"/>
                                        <xsl:variable name="scenario-tests" select="x:test-result"/>
                                        <xsl:variable name="scenarioid" select="concat($stepid,'-scenario',position())"/>
                                        <xsl:variable name="passed" select="count($scenario-description/x:test-result[@result='passed'])"/>
                                        <xsl:variable name="pending" select="count($scenario-description/x:test-result[@result='skipped'])"/>
                                        <xsl:variable name="failed" select="count($scenario-description/x:test-result[@result='failed'])"/>
                                        <xsl:variable name="total" select="count($scenario-description/x:test-result)"/>
                                        <xsl:variable name="scenario-class" select="if ($failed) then 'failed' else if ($pending) then 'pending' else if ($passed) then 'successful' else ''"/>

                                        <tr class="{$scenario-class} label">
                                            <th class="scenario-label">
                                                <xsl:value-of select="$scenario-description/x:scenario/@label"/>
                                            </th>
                                            <th class="nobr">passed:<xsl:value-of select="$passed"/> / pending:<xsl:value-of select="$pending"/> / failed:<xsl:value-of select="$failed"/> / errors:0 /
                                                    total:<xsl:value-of select="$total"/></th>
                                        </tr>

                                        <!-- for each step scenario context -->
                                        <xsl:for-each select="$scenario-contexts">
                                            <xsl:variable name="id" select="@id"/>
                                            <xsl:variable name="context-tests" select="$scenario-tests[@contextref=$id]"/>
                                            <xsl:variable name="contextid" select="concat($scenarioid,'-context',position())"/>
                                            <xsl:variable name="passed" select="count($context-tests[@result='passed'])"/>
                                            <xsl:variable name="pending" select="count($context-tests[@result='skipped'])"/>
                                            <xsl:variable name="failed" select="count($context-tests[@result='failed'])"/>
                                            <xsl:variable name="total" select="count($context-tests)"/>
                                            <xsl:variable name="context-class" select="if ($failed) then 'failed' else if ($pending) then 'pending' else if ($passed) then 'successful' else ''"/>
                                            <tr class="{$context-class} label">
                                                <th class="context-label">
                                                    <xsl:value-of select="@label"/>
                                                </th>
                                                <th class="nobr">passed:<xsl:value-of select="$passed"/> / pending:<xsl:value-of select="$pending"/> / failed:<xsl:value-of select="$failed"/> /
                                                    errors:0 / total:<xsl:value-of select="$total"/></th>
                                            </tr>
                                            <xsl:if test="$context-class='failed'">
                                                <tr class="was">
                                                    <td colspan="2">Was:</td>
                                                </tr>
                                                <xsl:variable name="context-documents" select="$scenario-description/x:scenario/x:context[@id=$id]/x:document"/>
                                                <xsl:choose>
                                                    <xsl:when test="count($context-documents)=0">
                                                        <tr class="was">
                                                            <td colspan="2">
                                                                <pre><code>(empty sequence)</code></pre>
                                                            </td>
                                                        </tr>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <tr class="was">
                                                            <td colspan="2">
                                                                <xsl:call-template name="print-context"/>
                                                            </td>
                                                        </tr>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:if>

                                            <!-- for each step scenario context test -->
                                            <xsl:for-each select="$context-tests">
                                                <xsl:variable name="test-class"
                                                    select="if (@result='failed') then 'failed' else if (@result='skipped') then 'pending' else if (@result='passed') then 'successful' else ''"/>
                                                <xsl:variable name="test-result"
                                                    select="if (@result='failed') then 'Failed' else if (@result='skipped') then 'Pending' else if (@result='passed') then 'Success' else '[Unknown]'"/>
                                                <tr class="{$test-class} label">
                                                    <td class="test-label">
                                                        <xsl:value-of select="@label"/>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="$test-result"/>
                                                    </td>
                                                </tr>
                                                <xsl:if test="$test-class='pending'">
                                                    <tr class="pending">
                                                        <td class="pending-label">
                                                            <xsl:value-of select="@pending"/>
                                                        </td>
                                                        <td> </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="$test-class='failed'">
                                                    <tr class="expected">
                                                        <td colspan="2">
                                                            <xsl:variable name="was" select="x:was"/>
                                                            <xsl:variable name="expected" select="x:expected"/>
                                                            <table>
                                                                <col width="50%"/>
                                                                <col width="50%"/>
                                                                <thead>
                                                                    <tr>
                                                                        <th>Result</th>
                                                                        <th>Expected</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody>
                                                                    <xsl:for-each select="1 to max((count($was),count($expected)))">
                                                                        <xsl:variable name="pos" select="."/>
                                                                        <xsl:variable name="this-was" select="$was[.]"/>
                                                                        <xsl:variable name="this-expected" select="$expected[.]"/>

                                                                        <tr>
                                                                            <td>
                                                                                <xsl:for-each select="$this-was">
                                                                                    <xsl:call-template name="print-context"/>
                                                                                </xsl:for-each>
                                                                            </td>
                                                                            <td>
                                                                                <xsl:for-each select="$this-expected">
                                                                                    <xsl:call-template name="print-context"/>
                                                                                </xsl:for-each>
                                                                            </td>
                                                                        </tr>
                                                                    </xsl:for-each>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:for-each>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                        </div>
                    </xsl:for-each>

                    <!-- for each script with pending scenarios -->
                    <xsl:for-each select="distinct-values($pending-descriptions/(x:step-declaration/*/@type,resolve-uri(@script,base-uri()))[1])">
                        <xsl:variable name="title" select="."/>
                        <xsl:variable name="pending-script-descriptions" select="$pending-descriptions[(x:step-declaration/*/@type,resolve-uri(@script,base-uri()))[1] = $title]"/>
                        <xsl:variable name="script-base" select="($pending-script-descriptions/resolve-uri(@script,base-uri()))[1]"/>
                        <div id="pending-{count($pending-script-descriptions[1]/preceding::x:description)}">
                            <h2 class="pending">Not calling: <a href="{$script-base}"><xsl:value-of select="$title"/></a><span class="scenario-totals">passed:0 / pending:<xsl:value-of
                                        select="count($pending-script-descriptions)"/> / failed:0 / errors:0 / total:<xsl:value-of select="count($pending-script-descriptions)"/></span></h2>
                            <table>
                                <col width="80%"/>
                                <col width="20%"/>
                                <tbody>
                                    <!-- for each pending scenario for the current script -->
                                    <xsl:for-each select="$pending-script-descriptions">
                                        <tr class="pending label">
                                            <th class="scenario-label">
                                                <xsl:value-of select="x:scenario/@label"/>
                                            </th>
                                            <th class="nobr">passed:0 / pending:1 / failed:0 / errors:0 / total:1</th>
                                        </tr>
                                        <tr class="pending">
                                            <td>
                                                <xsl:value-of select="x:scenario/@pending"/>
                                            </td>
                                            <td>Pending</td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                        </div>
                    </xsl:for-each>

                    <xsl:if test="$log">
                        <h2>Execution log</h2>
                        <xsl:apply-templates select="$log"/>
                    </xsl:if>

                </xsl:copy>
            </xsl:for-each>

        </xsl:copy>
    </xsl:template>

    <xsl:template match="c:log">
        <xsl:variable name="log" select="."/>
        <table>
            <thead>
                <tr>
                    <th>Time</th>
                    <th>Severity</th>
                    <th>Message</th>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="$log/c:line">
                    <tr
                        style="{if (@severity='DEBUG') then 'color:#696969;' else if (@severity='INFO') then '' else if (@severity='WARN') then 'background-color:#FFD700;' else if (@severity='ERROR') then 'background-color:#FF6347;' else ''}">
                        <td>
                            <xsl:variable name="t" select="replace(string(xs:dateTime(@time)-xs:dateTime($log/c:line[1]/@time)),'[^\d\.]','')"/>
                            <xsl:variable name="t" select="tokenize($t,'\.')"/>
                            <xsl:variable name="t" select="if (count($t)=1) then concat($t,'.000') else concat($t[1],'.',$t[2], string-join(for $pad in (string-length($t[2]) to 2) return '0', ''))"/>
                            <xsl:value-of select="$t"/>
                        </td>
                        <td style="padding-left:0%;">
                            <xsl:value-of select="@severity"/>
                        </td>
                        <td>
                            <code>
                                <pre><xsl:value-of select="./text()"/></pre>
                            </code>
                        </td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>

    <xsl:template match="p:* | c:*">
        <div class="pp-xml">
            <xsl:call-template name="pretty-print"/>
        </div>
    </xsl:template>

    <xsl:template match="x:description">
        <h3>xprocspec document metadata</h3>
        <div style="padding-left: 50px;">
            <dl>
                <xsl:for-each select="@*">
                    <dt>
                        <xsl:value-of select="name()"/>
                    </dt>
                    <dd>
                        <xsl:value-of select="string(.)"/>
                    </dd>
                </xsl:for-each>
            </dl>
            <xsl:apply-templates select="x:documentation | x:step-declaration | x:scenario"/>
        </div>
    </xsl:template>

    <xsl:template match="x:*">
        <h3>
            <xsl:variable name="name" select="local-name()"/>
            <xsl:choose>
                <xsl:when test="$name='step-declaration'">
                    <xsl:text>XProc step declaration</xsl:text>
                </xsl:when>
                <xsl:when test="$name='scenario'">
                    <xsl:text>Scenario</xsl:text>
                </xsl:when>
                <xsl:when test="$name='call'">
                    <xsl:text>Invocation</xsl:text>
                </xsl:when>
                <xsl:when test="$name='option'">
                    <xsl:text>Option</xsl:text>
                </xsl:when>
                <xsl:when test="$name='param'">
                    <xsl:text>Parameter</xsl:text>
                </xsl:when>
                <xsl:when test="$name='input'">
                    <xsl:text>Input port</xsl:text>
                </xsl:when>
                <xsl:when test="$name='context'">
                    <xsl:text>Test context</xsl:text>
                </xsl:when>
                <xsl:when test="$name='expect'">
                    <xsl:text>Assertion</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="name()"/>
                </xsl:otherwise>
            </xsl:choose>
        </h3>
        <div style="padding-left: 50px;">
            <dl>
                <xsl:for-each select="@*">
                    <dt>
                        <xsl:value-of select="name()"/>
                    </dt>
                    <dd>
                        <xsl:value-of select="string(.)"/>
                    </dd>
                </xsl:for-each>
            </dl>
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="self::x:* | self::c:*">
                        <xsl:apply-templates select="."/>
                    </xsl:when>
                    <xsl:when test="self::*">
                        <div class="pp-xml">
                            <xsl:call-template name="pretty-print"/>
                        </div>
                    </xsl:when>
                    <xsl:when test="self::text() and normalize-space(.)!=''">
                        <pre><code><xsl:copy-of select="."/></code></pre>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template match="x:documentation">
        <xsl:variable name="describes" select="parent::*/local-name()"/>
        <div style="padding-left: 50px;">
            <h4>
                <xsl:choose>
                    <xsl:when test="$describes='description'">
                        <xsl:text>Description of xprocspec document:</xsl:text>
                    </xsl:when>
                    <xsl:when test="$describes='step-declaration'">
                        <xsl:text>Description of XProc step declaration</xsl:text>
                    </xsl:when>
                    <xsl:when test="$describes='scenario'">
                        <xsl:text>Description of scenario:</xsl:text>
                    </xsl:when>
                    <xsl:when test="$describes='call'">
                        <xsl:text>Description of invocation (inputs/options/parameters):</xsl:text>
                    </xsl:when>
                    <xsl:when test="$describes='option'">
                        <xsl:text>Description of option</xsl:text>
                    </xsl:when>
                    <xsl:when test="$describes='param'">
                        <xsl:text>Description of parameter</xsl:text>
                    </xsl:when>
                    <xsl:when test="$describes='input'">
                        <xsl:text>Description of input port</xsl:text>
                    </xsl:when>
                    <xsl:when test="$describes='context'">
                        <xsl:text>Description of test context:</xsl:text>
                    </xsl:when>
                    <xsl:when test="$describes='expect'">
                        <xsl:text>Description of assertion:</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$describes"/>
                    </xsl:otherwise>
                </xsl:choose>
            </h4>
            <div style="padding-left: 50px;">
                <xsl:copy-of select="node()"/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="x:test-report">
        <h2>Test report</h2>
        <xsl:for-each select="node()">
            <xsl:choose>
                <xsl:when test="self::x:* | self::c:*">
                    <xsl:apply-templates select="."/>
                </xsl:when>
                <xsl:when test="self::*">
                    <div class="pp-xml">
                        <xsl:call-template name="pretty-print"/>
                    </div>
                </xsl:when>
                <xsl:when test="self::text() and normalize-space(.)!=''">
                    <pre><code><xsl:copy-of select="."/></code></pre>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="x:document">
        <xsl:param name="include-raw" select="false()" tunnel="yes"/>
        <xsl:if test="@xml:base">
            <p>Document base URI: <code><xsl:value-of select="@xml:base"/></code></p>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="@type='inline' or not(@type)">
                <xsl:for-each select="*">
                    <xsl:choose>
                        <xsl:when test="self::x:* | self::c:*">
                            <xsl:apply-templates select="."/>
                            <xsl:if test="$include-raw">
                                <div class="pp-xml">
                                    <xsl:call-template name="pretty-print"/>
                                </div>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <div class="pp-xml">
                                <xsl:call-template name="pretty-print"/>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <dl>
                    <xsl:for-each select="@*">
                        <dt>
                            <xsl:value-of select="name()"/>
                        </dt>
                        <dd>
                            <xsl:value-of select="string(.)"/>
                        </dd>
                    </xsl:for-each>
                </dl>
                <xsl:for-each select="node()">
                    <xsl:choose>
                        <xsl:when test="self::x:* | self::c:*">
                            <xsl:apply-templates select="."/>
                            <xsl:if test="$include-raw">
                                <div class="pp-xml">
                                    <xsl:call-template name="pretty-print"/>
                                </div>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="self::* and $include-raw">
                            <div class="pp-xml">
                                <xsl:call-template name="pretty-print"/>
                            </div>
                        </xsl:when>
                        <xsl:when test="self::text() and normalize-space(.)!='' and $include-raw">
                            <pre><code><xsl:copy-of select="."/></code></pre>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="c:errors">
        <p><xsl:value-of select="count(c:error)"/> errors found.</p>
        <dl>
            <xsl:for-each select="@*">
                <dt>
                    <xsl:value-of select="name()"/>
                </dt>
                <dd>
                    <xsl:value-of select="string(.)"/>
                </dd>
            </xsl:for-each>
        </dl>
        <xsl:for-each select="node()">
            <xsl:choose>
                <xsl:when test="self::x:* | self::c:*">
                    <xsl:apply-templates select="."/>
                </xsl:when>
                <xsl:when test="self::*">
                    <div class="pp-xml">
                        <xsl:call-template name="pretty-print"/>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <pre><code><xsl:copy-of select="."/></code></pre>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="c:error">
        <div style="border:2px solid;border-radius:5px;">
            <dl>
                <xsl:for-each select="@*">
                    <dt>
                        <xsl:value-of select="name()"/>
                    </dt>
                    <dd>
                        <xsl:value-of select="string(.)"/>
                    </dd>
                </xsl:for-each>
            </dl>
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="self::*">
                        <div class="pp-xml">
                            <xsl:call-template name="pretty-print"/>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <pre><code><xsl:copy-of select="."/></code></pre>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template name="pretty-print">
        <xsl:param name="indent" select="0"/>
        <xsl:element name="{if ($indent=0) then 'div' else 'span'}">
            <xsl:attribute name="class" select="if ($indent=0) then 'pp-element pp-document-element' else 'pp-element'"/>
            <xsl:choose>
                <xsl:when test="self::x:was | self::x:expected">
                    <xsl:for-each select="node()">
                        <xsl:call-template name="pretty-print"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="self::text()">
                    <pre><code><xsl:value-of select="."/></code></pre>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="indent-spaces" select="string-join(for $i in (1 to $indent) return '&#160;&#160;&#160;&#160;','')"/>
                    <br/>
                    <xsl:value-of select="$indent-spaces"/>
                    <span class="pp-tag-open">&lt;</span>
                    <span class="pp-tag-name">
                        <xsl:value-of select="local-name()"/>
                    </span>
                    <xsl:if test="$indent=0 or not(namespace-uri()=parent::*/namespace-uri())">
                        <xsl:text> </xsl:text>
                        <span class="pp-attr-name">xmlns=</span>
                        <span class="pp-attr-value">
                            <xsl:text>"</xsl:text>
                            <xsl:value-of select="namespace-uri()"/>
                            <xsl:text>"</xsl:text>
                        </span>
                    </xsl:if>
                    <xsl:for-each select="@*">
                        <xsl:text> </xsl:text>
                        <span class="pp-attr-name">
                            <xsl:value-of select="name()"/>
                            <xsl:text>=</xsl:text>
                        </span>
                        <span class="pp-attr-value">
                            <xsl:text>"</xsl:text>
                            <xsl:value-of select="string(.)"/>
                            <xsl:text>"</xsl:text>
                        </span>
                    </xsl:for-each>
                    <xsl:choose>
                        <xsl:when test="not(node())">
                            <span class="pp-tag-close">/&gt;</span>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="pp-tag-close">&gt;</span>
                            <xsl:for-each select="node()">
                                <xsl:choose>
                                    <xsl:when test="self::*">
                                        <xsl:call-template name="pretty-print">
                                            <xsl:with-param name="indent" select="$indent+1"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                            <xsl:if test="*">
                                <br/>
                                <xsl:value-of select="$indent-spaces"/>
                            </xsl:if>
                            <span class="pp-tag-open">&lt;</span>
                            <xsl:text>/</xsl:text>
                            <span class="pp-tag-name">
                                <xsl:value-of select="local-name()"/>
                            </span>
                            <span class="pp-tag-close">&gt;</span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
        <xsl:if test="$indent=0">
            <br/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="print-context">
        <xsl:choose>
            <xsl:when test="not(*)">
                <pre><code><xsl:copy-of select="."/></code></pre>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="node()">
                    <xsl:choose>
                        <xsl:when test="self::text() and normalize-space(.)=''"/>
                        <xsl:when test="self::x:document">
                            <xsl:apply-templates select=".">
                                <xsl:with-param name="include-raw" select="true()" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:when test="self::x:* | self::c:*">
                            <xsl:apply-templates select=".">
                                <xsl:with-param name="include-raw" select="true()" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <div class="pp-xml">
                                <xsl:call-template name="pretty-print"/>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
