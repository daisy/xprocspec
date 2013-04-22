<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0" exclude-result-prefixes="#all" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <!--
        http://stackoverflow.com/a/9691131/281065
        https://svn.jenkins-ci.org/trunk/hudson/dtkit/dtkit-format/dtkit-junit-model/src/main/resources/com/thalesgroup/dtkit/junit/model/xsd/junit-4.xsd
    -->

    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="/*">
        <xsl:variable name="declaration" select="x:description/x:step-declaration/*"/>
        <xsl:variable name="scenario" select="x:description/x:scenario"/>
        <xsl:variable name="tests" select="x:test-result"/>

        <testsuite name="{x:camelCase($scenario/@label)}" package="{replace($declaration/@x:type,'^\{(.*)\}.*','$1')}" timestamp="{x:now()}" hostname="localhost" tests="{count($tests)}" errors="0" failures="{count($tests[not(@result='true')])}"
            skipped="false" disabled="false" id="{generate-id()}" time="0">
            <!--
                TODO: @time: Time taken (in seconds) to execute the tests in the suite
            -->

            <xsl:text>
</xsl:text>
            <properties>
                <xsl:if test="$scenario/x:call/x:input">
                    <xsl:variable name="include-xml-base" select="if ($scenario/x:call/x:input/x:document/@xml:base) then true() else false()"/>
                    <xsl:for-each select="$scenario/x:call/x:input">
                        <property name="input: {@port}">
                            <xsl:attribute name="value">
                                <xsl:for-each select="*[position() &lt; 5]">
                                    <xsl:value-of
                                        select="concat(
                                                '&lt;',*/local-name(),' xmlns=&quot;',*/namespace-uri(),'&quot;',
                                                if (.[@*]) then ' ...' else '',
                                                if (*/node()) then concat('&gt;...&lt;/',*/local-name(),'&gt;') else '/&gt;',
                                                if ($include-xml-base) then concat(' (Base URI: ',@xml:base,')') else ''
                                                )"/>
                                    <xsl:if test="following-sibling::*">
                                        <xsl:value-of select="'&#xA;'"/>
                                    </xsl:if>
                                </xsl:for-each>
                                <xsl:if test="count(*) &gt; 5">
                                    <xsl:value-of select="concat('... ',(count(*)-5),' more documents (a total of ',count(*),') ...')"/>
                                </xsl:if>
                            </xsl:attribute>
                        </property>
                    </xsl:for-each>
                </xsl:if>
                <xsl:text>
</xsl:text>
                <xsl:if test="$scenario/x:call/x:option">
                    <xsl:for-each select="$scenario/x:call/x:option">
                        <xsl:text>
</xsl:text>
                        <property name="option: {@name}">
                            <xsl:attribute name="value">
                                <xsl:evaluate xpath="@select"/>
                            </xsl:attribute>
                        </property>
                    </xsl:for-each>
                </xsl:if>
                <xsl:text>
</xsl:text>
                <xsl:if test="$scenario/x:call/x:param">
                    <xsl:for-each select="$scenario/x:call/x:param">
                        <xsl:text>
</xsl:text>
                        <property name="parameter: {@name}">
                            <xsl:attribute name="value">
                                <xsl:evaluate xpath="@select"/>
                            </xsl:attribute>
                        </property>
                    </xsl:for-each>
                </xsl:if>
                <xsl:text>
</xsl:text>
            </properties>
            <xsl:text>
</xsl:text>

            <xsl:for-each select="$tests">
                <testcase name="{x:camelCase(@label)}" classname="{tokenize($declaration/@type,':')[last()]}" assertions="1" status="{if (@result='true') then 'SUCCESS' else 'FAILED'}" time="0">
                    <!--
                        TODO: @time: Time taken (in seconds) to execute the test
                    -->

                    <xsl:if test="false()">
                        <skipped><!-- TODO (string describing why it was skipped?) --></skipped>
                    </xsl:if>

                    <xsl:variable name="message" select="concat($scenario/@label,' ',@label)"/>

                    <xsl:choose>
                        <xsl:when test="@result='true'">
                            <!-- success -->
                            <system-out>
                                <xsl:value-of select="concat($message,': SUCCESS')"/>
                            </system-out>
                        </xsl:when>
                        <xsl:when test="false()">
                            <!-- TODO: not implemented -->
                            <!-- static error -->
                            <error message="{$message}" type="TODO string optional"/>
                            <system-out>
                                <xsl:value-of select="concat($message,': ERROR')"/>
                            </system-out>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- unexpected dynamic error -->
                            <failure message="{$message}" type="TODO string optional"/>
                            <system-out>
                                <xsl:value-of select="concat($message,': FAILED')"/>
                            </system-out>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>
</xsl:text>

                    <system-err>
                        <xsl:if test="not(@result='true')">
                            <xsl:if test="./c:expected">
                                <xsl:text>Expected:
</xsl:text>
                                <xsl:value-of select="./c:expected"/>
                            </xsl:if>
                            <xsl:text>

</xsl:text>
                            <xsl:if test="./c:was">
                                <xsl:text>Was:
</xsl:text>
                                <xsl:value-of select="./c:was"/>
                            </xsl:if>
                        </xsl:if>
                    </system-err>
                </testcase>
            </xsl:for-each>
        </testsuite>
    </xsl:template>


    <xsl:function name="x:now" as="xs:string">
        <xsl:value-of select="adjust-dateTime-to-timezone(current-dateTime(),xs:dayTimeDuration('PT0H'))"/>
    </xsl:function>

    <xsl:function name="x:camelCase" as="xs:string">
        <xsl:param name="string"/>
        <xsl:variable name="string" select="replace(replace($string,'\s+',' '),'[^\w ]','')"/>
        <xsl:value-of
            select="string-join(
                            (for $i in 1 to count(tokenize($string,' ')),
                                $s in tokenize($string,' ')[$i],
                                $fl in substring($s,1,1),
                                $tail in substring($s,2)
                            return
                                if($i eq 1)
                                    then $s
                                    else concat(upper-case($fl), $tail)
                            ),
                            ''
            )"
        />
    </xsl:function>

</xsl:stylesheet>
