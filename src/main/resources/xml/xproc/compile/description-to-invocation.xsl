<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:p="http://www.w3.org/ns/xproc" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test" xmlns:c="http://www.w3.org/ns/xproc-step" exclude-result-prefixes="#all">

    <xsl:output indent="yes" method="xml"/>
    <xsl:param name="name" required="yes"/>

    <xsl:template match="/x:description">
        <p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="x:{$name}" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" xpath-version="2.0">
            <xsl:namespace name="x" select="'http://www.daisy.org/ns/pipeline/xproc/test'"/>
            <xsl:text>
    </xsl:text>
            <p:output port="result"/>
            <xsl:text>
    </xsl:text>
            <p:import href="{resolve-uri(@script,base-uri(.))}"/>

            <xsl:choose>
                <xsl:when test="x:scenario[@pending]">
                    <xsl:text>
    </xsl:text>
                    <xsl:comment select="'This test is marked as pending and will be skipped.'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>

    </xsl:text>
                    <xsl:element name="test:{tokenize(/*/x:step-declaration/*/@x:type,'\}')[last()]}" namespace="{replace(/*/x:step-declaration/*/@x:type,'\{(.*)\}.*','$1')}">
                        <xsl:attribute name="name" select="'test'"/>
                        <xsl:for-each select="/*/x:scenario/x:call/x:option">
                            <xsl:text>
        </xsl:text>
                            <p:with-option name="{@name}" select="{@select}">
                                <p:inline>
                                    <context>TODO</context>
                                </p:inline>
                            </p:with-option>
                            <!-- TODO: set context for p:with-option -->
                        </xsl:for-each>
                        <xsl:for-each select="/*/x:scenario/x:call/x:param">
                            <xsl:text>
        </xsl:text>
                            <p:with-param name="{@name}" select="{@select}">
                                <p:inline>
                                    <context>TODO</context>
                                </p:inline>
                            </p:with-param>
                            <!-- TODO: set context for p:with-param -->
                        </xsl:for-each>
                        <xsl:for-each select="/*/x:scenario/x:call/x:input">
                            <xsl:text>
        </xsl:text>
                            <p:input port="{@port}">
                                <xsl:copy-of select="@select">
                                    <!-- TODO: @select won't resolve namespaces correctly in this dynamically evaluated xpath context -->
                                </xsl:copy-of>
                                
                                <xsl:variable name="port" select="@port"/>
                                <xsl:variable name="declaration" select="/*/x:step-declaration/*/p:input[@port=$port]"/>
                                <xsl:variable name="kind" select="$declaration/('document',@kind)[last()]"/>
                                <xsl:variable name="primary" select="$declaration/@primary='true' or not($declaration/@primary='false') and count(/*/x:step-declaration/*/p:input[(@kind,'document')[1]=$kind])=1"/>
                                <xsl:if test="not(x:document) and $primary">
                                    <!-- "A default connection does not satisfy the requirement that a primary input port is automatically connected by the processor, nor is it used when no default readable port is defined. In other words, a p:declare-step or a p:pipeline can define defaults for all of its inputs, whether they are primary or not, but defining a default for a primary input usually has no effect. It's never used by an atomic step since the step, when it's called, will always connect the primary input port to the default readable port (or cause a static error). The only case where it has value is on a p:pipeline when that pipeline is invoked directly by the processor. In that case, the processor must use the default connection if no external connection is provided for the port." (http://www.w3.org/TR/xproc/#document-inputs)
                                    
                                    If no input has been given to the primary port; use the default connection.
                                    -->
                                    <xsl:copy-of select="$declaration/*"/>
                                </xsl:if>
                                <xsl:for-each select="x:document">
                                    <xsl:choose>
                                        <xsl:when test="*">
                                            <p:inline>
                                                <xsl:copy-of select="@xml:base"/>
                                                <xsl:copy-of select="*"/>
                                            </p:inline>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <p:document href="{@href}"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </p:input>
                        </xsl:for-each>
                    </xsl:element>
                    <xsl:text>
    </xsl:text>
                    <p:sink>
                        <p:input port="source">
                            <p:empty/>
                        </p:input>
                    </p:sink>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:for-each select="/*/x:step-declaration/*/p:output">
                <xsl:text>

    </xsl:text>
                <p:wrap-sequence wrapper="x:output">
                    <xsl:text>
        </xsl:text>
                    <p:input port="source">
                        <xsl:text>
            </xsl:text>
                        <p:pipe port="{@port}" step="test"/>
                        <xsl:text>
        </xsl:text>
                    </p:input>
                    <xsl:text>
    </xsl:text>
                </p:wrap-sequence>
                <xsl:text>
    </xsl:text>
                <p:add-attribute match="/*" attribute-name="port" attribute-value="{@port}"/>
                <xsl:text>
    </xsl:text>
                <p:identity name="output.{@port}"/>
                <xsl:text>
    </xsl:text>
                <p:sink/>
            </xsl:for-each>

            <xsl:text>

    </xsl:text><p:insert match="/*" position="last-child">
                <xsl:text>
        </xsl:text><p:input port="source">
                    <xsl:text>
            </xsl:text><p:inline exclude-inline-prefixes="#all">
                        <xsl:for-each select="/*">
                            <xsl:copy>
                                <xsl:copy-of select="@*|node()"/>
                            </xsl:copy>
                        </xsl:for-each>
                        <xsl:text>
            </xsl:text></p:inline>
                    <xsl:text>
        </xsl:text></p:input>
                <xsl:text>
        </xsl:text><p:input port="insertion">
                    <xsl:for-each select="/*/x:step-declaration/*/p:output">
                        <xsl:text>
            </xsl:text><p:pipe port="result" step="output.{@port}"/>
                    </xsl:for-each>
            <xsl:text>
        </xsl:text></p:input>
        <xsl:text>
    </xsl:text></p:insert>
            <xsl:text>
</xsl:text></p:declare-step>
    </xsl:template>

</xsl:stylesheet>
