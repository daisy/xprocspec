<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="px:test-compile" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test">

    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true" primary="true">
        <p:pipe port="result" step="result"/>
    </p:output>

    <p:for-each>
        <!-- convert each x:description/scenario/x:call to an XProc script -->
        <p:choose>
            <p:when test="/*[self::c:errors]">
                <p:identity/>
            </p:when>
            <p:otherwise>
                <p:variable name="base" select="base-uri(/*)"/>
                <p:try>
                    <p:group>
                        <p:xslt>
                            <p:with-param name="name" select="concat('test',p:iteration-position())"/>
                            <p:input port="stylesheet">
                                <p:document href="description-to-invocation.xsl"/>
                            </p:input>
                        </p:xslt>
                        <p:wrap-sequence wrapper="calabash-issue-102"/>
                    </p:group>
                    <p:catch name="catch">
                        <p:identity>
                            <p:input port="source">
                                <p:pipe port="error" step="catch"/>
                            </p:input>
                        </p:identity>
                        <p:add-attribute match="/*" attribute-name="xml:base">
                            <p:with-option name="attribute-value" select="$base"/>
                        </p:add-attribute>
                        <p:wrap-sequence wrapper="calabash-issue-102"/>
                    </p:catch>
                </p:try>
                <p:for-each>
                    <!-- temporary fix for https://github.com/ndw/xmlcalabash1/issues/102 -->
                    <p:iteration-source select="/calabash-issue-102/*"/>
                    <p:identity/>
                </p:for-each>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    <p:identity name="result"/>

</p:declare-step>
