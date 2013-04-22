<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="px:test-evaluate" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="#all"
    version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" pkg:import-uri="http://josteinaj.no/ns/2013/xprocspec/evaluate.xpl" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test">

    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>
    
    <p:import href="compare.xpl"/>
    
    <p:for-each>
        <!-- for each scenario -->
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
                        <p:variable name="result" select="/*/@result"/>
                        
                        <p:wrap-sequence wrapper="c:was" name="was">
                            <p:input port="source">
                                <p:pipe port="result" step="output-port"/>
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
    </p:for-each>

</p:declare-step>
