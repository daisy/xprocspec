<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="px:test-evaluate" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test">

    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>

    <p:import href="compare.xpl"/>

    <p:for-each>
        <!-- for each scenario -->
        <p:choose>
            <p:when test="/*[self::c:errors]">
                <p:identity name="c-error"/>
                <p:wrap-sequence wrapper="x:description"/>
                <p:wrap-sequence wrapper="x:scenario-results" name="without-test-result"/>
                <p:wrap-sequence wrapper="c:was">
                    <p:input port="source">
                        <p:pipe port="result" step="c-error"/>
                    </p:input>
                </p:wrap-sequence>
                <p:wrap-sequence wrapper="x:test-result"/>
                <p:add-attribute match="/*" attribute-name="result" attribute-value="false"/>
                <p:add-attribute match="/*" attribute-name="test-type" attribute-value="compile"/>
                <p:add-attribute match="/*" attribute-name="label">
                    <p:with-option name="attribute-value" select="concat('Compilation error: ',/*/*/*/@xml:base)"/>
                </p:add-attribute>
                <p:identity name="test-result"/>
                <p:insert position="last-child" match="/*">
                    <p:input port="source">
                        <p:pipe port="result" step="without-test-result"/>
                    </p:input>
                    <p:input port="insertion">
                        <p:pipe port="result" step="test-result"/>
                    </p:input>
                </p:insert>
            </p:when>
            <p:otherwise>
                <p:identity name="description"/>
                <p:for-each name="test">
                    <!-- for each test in the scenario -->
                    <p:iteration-source select="/x:description/x:scenario/x:expect"/>
                    <p:variable name="port" select="/*/@port"/>

                    <p:filter name="output-port">
                        <p:with-option name="select" select="concat('/x:description/x:output[@port=&quot;',$port,'&quot;]/*')">
                            <p:inline>
                                <doc/>
                            </p:inline>
                        </p:with-option>
                        <p:input port="source">
                            <p:pipe port="result" step="description"/>
                        </p:input>
                    </p:filter>

                    <p:identity name="errors">
                        <p:input port="source" select="/x:description/c:errors">
                            <p:pipe port="result" step="description"/>
                        </p:input>
                    </p:identity>

                    <p:identity>
                        <p:input port="source">
                            <p:pipe port="current" step="test"/>
                        </p:input>
                    </p:identity>

                    <p:choose>
                        <p:when test="/*[@test]">
                            <!-- evaluate @test against x:output[@port=$port] -->
                            <p:variable name="test" select="/*/@test"/>

                            <!-- the XPath expression must evalutate to true() for all documents on the output port, and there must be at least one document on the output port -->
                            <p:for-each>
                                <p:iteration-source>
                                    <p:pipe port="result" step="output-port"/>
                                </p:iteration-source>
                                <p:filter>
                                    <p:with-option name="select" select="concat('if (',$test,') then /* else /*[false()]')"/>
                                    <p:input port="source">
                                        <p:pipe port="result" step="output-port"/>
                                    </p:input>
                                </p:filter>
                                <p:count/>
                            </p:for-each>
                            <p:wrap-sequence wrapper="c:result"/>
                            <p:add-attribute match="/*" attribute-name="result">
                                <p:with-option name="attribute-value" select="/c:result/c:result and not((for $result in (/c:result/c:result/number(.)) return $result &gt; 0) = false())"/>
                            </p:add-attribute>
                            <p:delete match="/c:result/c:result"/>
                            <p:identity name="test-result"/>

                            <p:group>
                                <p:wrap-sequence wrapper="c:was" name="was">
                                    <p:input port="source">
                                        <p:pipe port="result" step="output-port"/>
                                        <p:pipe port="result" step="errors"/>
                                    </p:input>
                                </p:wrap-sequence>

                                <p:string-replace match="/*/text()" name="expected">
                                    <p:with-option name="replace" select="concat('&quot;',$test,'&quot;')"/>
                                    <p:input port="source">
                                        <p:inline>
                                            <c:expected>EXPECTED</c:expected>
                                        </p:inline>
                                    </p:input>
                                </p:string-replace>

                                <p:insert match="/*" position="last-child">
                                    <p:input port="source">
                                        <p:pipe port="result" step="test-result"/>
                                    </p:input>
                                    <p:input port="insertion">
                                        <p:pipe port="result" step="was"/>
                                        <p:pipe port="result" step="expected"/>
                                    </p:input>
                                </p:insert>
                            </p:group>

                            <p:add-attribute match="/*" attribute-name="test-type" attribute-value="xpath"/>
                        </p:when>
                        <p:when test="/*[@error]">
                            <p:variable name="error" select="/*/@error"/>

                            <p:choose>
                                <p:xpath-context>
                                    <p:pipe port="result" step="description"/>
                                </p:xpath-context>
                                <p:when test="/x:description/c:errors/c:error[@code=$error]">
                                    <p:identity>
                                        <p:input port="source">
                                            <p:inline>
                                                <c:result result="true"/>
                                            </p:inline>
                                        </p:input>
                                    </p:identity>
                                </p:when>
                                <p:otherwise>
                                    <p:identity>
                                        <p:input port="source">
                                            <p:inline>
                                                <c:result result="false"/>
                                            </p:inline>
                                        </p:input>
                                    </p:identity>
                                </p:otherwise>
                            </p:choose>
                            <p:identity name="test-result"/>

                            <p:group>
                                <p:wrap-sequence wrapper="c:was" name="was">
                                    <p:input port="source">
                                        <p:pipe port="result" step="errors"/>
                                    </p:input>
                                </p:wrap-sequence>

                                <p:string-replace match="/*/text()" name="expected">
                                    <p:with-option name="replace" select="concat('&quot;',$error,'&quot;')"/>
                                    <p:input port="source">
                                        <p:inline>
                                            <c:expected>EXPECTED</c:expected>
                                        </p:inline>
                                    </p:input>
                                </p:string-replace>

                                <p:insert match="/*" position="last-child">
                                    <p:input port="source">
                                        <p:pipe port="result" step="test-result"/>
                                    </p:input>
                                    <p:input port="insertion">
                                        <p:pipe port="result" step="was"/>
                                        <p:pipe port="result" step="expected"/>
                                    </p:input>
                                </p:insert>
                            </p:group>

                            <p:add-attribute match="/*" attribute-name="test-type" attribute-value="error"/>
                        </p:when>
                        <p:otherwise>
                            <p:for-each name="expect">
                                <p:output port="result" sequence="true"/>
                                <p:iteration-source select="/x:expect/x:document"/>
                                <p:choose>
                                    <p:when test="@href">
                                        <p:load>
                                            <p:with-option name="href" select="@href"/>
                                        </p:load>
                                    </p:when>
                                    <p:otherwise>
                                        <p:for-each>
                                            <p:iteration-source select="/x:document/*"/>
                                            <p:identity/>
                                        </p:for-each>
                                    </p:otherwise>
                                </p:choose>
                            </p:for-each>

                            <p:filter>
                                <p:with-option name="select" select="concat('/x:description/x:output[@port=&quot;',$port,'&quot;]/*')">
                                    <p:inline>
                                        <doc/>
                                    </p:inline>
                                </p:with-option>
                                <p:input port="source">
                                    <p:pipe port="result" step="description"/>
                                </p:input>
                            </p:filter>

                            <px:compare>
                                <p:input port="source">
                                    <p:pipe port="result" step="output-port"/>
                                </p:input>
                                <p:input port="alternate">
                                    <p:pipe port="result" step="expect"/>
                                </p:input>
                            </px:compare>
                            <p:insert match="c:was" position="last-child">
                                <p:input port="insertion">
                                    <p:pipe port="result" step="errors"/>
                                </p:input>
                            </p:insert>

                            <p:add-attribute match="/*" attribute-name="test-type" attribute-value="xml"/>
                        </p:otherwise>
                    </p:choose>
                    <p:rename match="/*" new-name="x:test-result"/>
                    <p:set-attributes match="/*">
                        <p:input port="attributes">
                            <p:pipe port="current" step="test"/>
                        </p:input>
                    </p:set-attributes>
                </p:for-each>

                <p:wrap-sequence wrapper="x:scenario-results"/>
                <p:insert match="/*" position="first-child">
                    <p:input port="insertion">
                        <p:pipe port="result" step="description"/>
                    </p:input>
                </p:insert>
            </p:otherwise>
        </p:choose>

    </p:for-each>

</p:declare-step>
