
############ funtions of the Tokening ###############

function keywords(token, currentfile, newFile)
    global keyword
    global symbol
    println(newFile, "<keyword> "*token*" </keyword>")
end


function symbols(token, currentfile, newFile)  
    global keyword
    global symbol
    if token=='>'
        println(newFile, "<symbol> &gt; </symbol>")
        token=""                                        # enter to token "" for initialization
    elseif token=='<'
        println(newFile, "<symbol> &lt; </symbol>")
        token=""
    elseif token=='\"'     # refer to the " , in jack is quote
        println(newFile, "<symbol> &quet; </symbol>")
        token=""
    elseif token=='&'
        println(newFile, "<symbol> &amp; </symbol>")
        token=""
    else
        println(newFile, "<symbol> "*token* " </symbol>")
        token=""
    end
end


function identifier(token, currentfile, newFile)
    global keyword
    global symbol
    while !(token[end] in symbol) && !(token[end]==' ') && !(token[end]=="\n") && !eof(currentfile)  # if not one of them then -
         token=token*string(read(currentfile, Char))    # connects(chain) all values ​​to a single string
     end
    println(newFile, "<identifier> "*token[1:end-1]*" </identifier>")
    if token[end] in symbol
        symbols(token[end], currentfile,newFile)        
    else
        token=""                                       # enter to token "" for initialization
    end
end


function StringConstant(token, currentfile, newFile)
    if !eof(currentfile)
        token=""
        token=token*string(read(currentfile, Char))
    end
    while !endswith(token, "\"") && !eof(currentfile)
        token=token*string(read(currentfile, Char))
    end
    println(newFile, "<stringConstant> "*token[1:end-1]* " </stringConstant>")
    token=""                                                    # enter to token "" for initialization
end


function IntegerConstant(token, currentfile, newFile)
    global keyword
    global symbol
    if !eof(currentfile)
        token=token*string(read(currentfile, Char))   # connects(chain) all values ​​to a single string
    end
    while all(isdigit, token) && !eof(currentfile)    # while is integerConstant or the file is`nt end 
        token=token*string(read(currentfile, Char))   # connects(chain) all values ​​to a single string
    end
    println(newFile, "<integerConstant> "*token[1:end-1]* " </integerConstant>")
    if token[end] in symbol
        symbols(token[end], currentfile,newFile)
    else
        token=""                                     # enter to token "" for initialization
    end
end

function letters(token, currentfile,newFile)
    global keyword
    global symbol
    if !eof(currentfile)
        token=token*string(read(currentfile, Char))      # connects(chain) all values ​​to a single string
    end
    while all(isletter, token) && !eof(currentfile)      # while isletter or the file is`nt end 
        token=token*string(read(currentfile, Char))
    end
    if token[1:end-1] in keyword
        keywords(token[1:end-1], currentfile,newFile)
        if token[end] in symbol
            symbols(token[end], currentfile,newFile)
        else
            token=""                                    # enter to token "" for initialization
        end
    else
        identifier(token, currentfile,newFile)
    end
end

function comments(token, currentfile)  # comments in jack can look: // or /*
    global keyword
    global symbol
    if token=='/' && !eof(currentfile)     # that mean is: //
        line=readline(currentfile)
        token=""                           # enter to token "" for initialization
    elseif token=='*' && !eof(currentfile) # that mean is: /*
        token=string(read(currentfile, Char))   # connects(chain) all values ​​to a single string
        while !endswith(token, "*/")  && !eof(currentfile)
            token=token*string(read(currentfile, Char))
        end
        token=""                           # enter to token "" for initialization
    end
end






############ funtions of the Parsing ###############

function GetNextToken(tokens) # Checks if we have not reached the end and if not return tokens[index]
    global index
    if index+1<=length(tokens) 
        index=index+1
        return tokens[index]
    end
end


function CheckNextToken(tokens)   # Checks if we have not reached the end and if not advances to the next token
    global index
    if index+1<=length(tokens)
        return tokens[index+1]
    end
end


function ParseClass(tokens, newFile)
    global index
    println(newFile, "<class>")
    println(newFile, GetNextToken(tokens))    #<keyword> class </keyword
    println(newFile, GetNextToken(tokens))    #<identifier> className </identifier>
    println(newFile, GetNextToken(tokens))    #<symbol> { </symbol>
    ParseClassVarDec(tokens, newFile)         # classVarDec
    ParseClassSubroutineDec(tokens, newFile)  # subroutineDec
    println(newFile, GetNextToken(tokens))     #<symbol> } </symbol>
    println(newFile, "</class>")
end


function ParseClassVarDec(tokens, newFile)
    while occursin("static",CheckNextToken(tokens)) || occursin("field",CheckNextToken(tokens))    # while the next token contain "static" or "field"
        println(newFile, "<classVarDec>")
        println(newFile, GetNextToken(tokens))     #<keyword> static/field </keyword>
        println(newFile, GetNextToken(tokens))     #<keyword> type </keyword>
        println(newFile, GetNextToken(tokens))     #<identifier> varName </identifier>
        while occursin( ",",CheckNextToken(tokens))
            println(newFile, GetNextToken(tokens)) #<symbol> , </symbol>
            println(newFile, GetNextToken(tokens)) #<identifier> varName </identifier>
        end
        println(newFile, GetNextToken(tokens))     #<symbol> ; </symbol>
        println(newFile, "</classVarDec>")
    end
end


function ParseClassSubroutineDec(tokens, newFile)
    while occursin( "method",CheckNextToken(tokens)) || occursin("function",CheckNextToken(tokens)) || occursin("constructor",CheckNextToken(tokens))  # while the next token contain "method" or "function" or "constructor"
        println(newFile, "<subroutineDec>")
        println(newFile, GetNextToken(tokens)) #<keyword> method/constructor/function </keyword>
        println(newFile, GetNextToken(tokens)) #<keyword> void </keyword>  /  <identifier> type </identifier>
        println(newFile, GetNextToken(tokens)) #<identifier> subroutineName </identifier>
        println(newFile, GetNextToken(tokens)) #<symbol> ( </symbol>
        ParseParameterList(tokens, newFile)    # parameterList
        println(newFile, GetNextToken(tokens)) #<symbol> ) </symbol>
        ParseSubroutineBody(tokens, newFile)   # subroutineBody
        println(newFile, "</subroutineDec>")
    end
end


function ParseParameterList(tokens, newFile)   # list of the parameter that the function get
    println(newFile, "<parameterList>")
    while !occursin( ")",CheckNextToken(tokens))
        println(newFile, GetNextToken(tokens))     #<keyword> type </keyword>
        println(newFile, GetNextToken(tokens))     #<identifier> varName </identifier>
        while occursin(",",CheckNextToken(tokens))
            println(newFile, GetNextToken(tokens)) #<symbol> , </symbol>
            println(newFile, GetNextToken(tokens)) #<keyword> type </keyword>
            println(newFile, GetNextToken(tokens)) #<identifier> varName </identifier>
        end
    end
    println(newFile, "</parameterList>")
end


function ParseSubroutineBody(tokens, newFile)
    println(newFile, "<subroutineBody>")
    println(newFile, GetNextToken(tokens)) #<symbol> { </symbol>
    ParseVarDec(tokens, newFile)           # varDec
    ParseStatements(tokens, newFile)       #statements
    println(newFile, GetNextToken(tokens)) #<symbol> } </symbol>
    println(newFile, "</subroutineBody>")
end


function ParseVarDec(tokens, newFile)
    while occursin("var",CheckNextToken(tokens))
        println(newFile, "<varDec>")
        println(newFile, GetNextToken(tokens))     #<keyword> var </keyword>
        println(newFile, GetNextToken(tokens))     #<keyword> type </keyword>
        println(newFile, GetNextToken(tokens))     #<identifier> varName </identifier>
        while occursin( ",",CheckNextToken(tokens))
            println(newFile, GetNextToken(tokens)) #<symbol> , </symbol>
            println(newFile, GetNextToken(tokens)) #<identifier> varName </identifier>
        end
        println(newFile, GetNextToken(tokens)) #<symbol> ; </symbol>
        println(newFile, "</varDec>")
    end
end


function ParseStatements(tokens, newFile)
    println(newFile, "<statements>")
                  # while the next token contain "let" or "if" or "while" or "do" or "return"
    while occursin( "let",CheckNextToken(tokens)) || occursin( "if",CheckNextToken(tokens)) || occursin( "while",CheckNextToken(tokens)) || occursin( "do",CheckNextToken(tokens)) || occursin( "return",CheckNextToken(tokens))
        if occursin("let",CheckNextToken(tokens))
            ParseLetStatement(tokens, newFile)    # letStatement
        elseif occursin("if",CheckNextToken(tokens))
            ParseIfStatement(tokens, newFile)     # ifStatement
        elseif occursin("while",CheckNextToken(tokens))
            ParseWhileStatement(tokens, newFile)  # whileStatement
        elseif occursin( "do",CheckNextToken(tokens))
            ParseDoStatement(tokens, newFile)     # doStatement
        elseif occursin( "return",CheckNextToken(tokens))
            ParseReturnStatement(tokens, newFile) # returnStatement
        end
    end
    println(newFile, "</statements>")
end


function ParseLetStatement(tokens, newFile)
    println(newFile, "<letStatement>")
    println(newFile, GetNextToken(tokens))     #<keyword> let </keyword>
    println(newFile, GetNextToken(tokens))     #<identifier> varName </identifier>
    if occursin( "[",CheckNextToken(tokens))
        println(newFile, GetNextToken(tokens)) #<symbol> [ </symbol>
            ParseExpression(tokens, newFile)   # expression
        println(newFile, GetNextToken(tokens)) #<symbol> ] </symbol>
    end
    println(newFile, GetNextToken(tokens))     #<symbol> = </symbol>
    ParseExpression(tokens, newFile)           # expression
    println(newFile, GetNextToken(tokens))     #<symbol> ; </symbol>
    println(newFile, "</letStatement>")
end


function ParseIfStatement(tokens, newFile)
    println(newFile, "<ifStatement>")
    println(newFile, GetNextToken(tokens)) #<keyword> if </keyword>
    println(newFile, GetNextToken(tokens)) #<symbol> ( </symbol>
    ParseExpression(tokens, newFile)       #  expression
    println(newFile, GetNextToken(tokens)) #<symbol> ) </symbol>
    println(newFile, GetNextToken(tokens)) #<symbol> { </symbol>
    ParseStatements(tokens, newFile)       # statements
    println(newFile, GetNextToken(tokens)) #<symbol> } </symbol>
    if occursin( "else",CheckNextToken(tokens))  
        println(newFile, GetNextToken(tokens)) #<keyword> else </keyword>
        println(CheckNextToken(tokens))        #<keyword> let </keyword>
        println(newFile, GetNextToken(tokens)) #<symbol> { </symbol>
        ParseStatements(tokens, newFile)       #statements
        println(newFile, GetNextToken(tokens)) #<symbol> } </symbol>
    end
    println(newFile, "</ifStatement>")
end


function ParseWhileStatement(tokens, newFile)
    println(newFile, "<whileStatement>")
    println(newFile, GetNextToken(tokens)) #<keyword> while </keyword>
    println(newFile, GetNextToken(tokens)) #<symbol> ( </symbol>
    ParseExpression(tokens, newFile)       # expression
    println(newFile, GetNextToken(tokens)) #<symbol> ) </symbol>
    println(newFile, GetNextToken(tokens)) #<symbol> { </symbol>
    ParseStatements(tokens, newFile)       # statements
    println(newFile, GetNextToken(tokens)) #<symbol> } </symbol>
    println(newFile, "</whileStatement>")
end


function ParseDoStatement(tokens, newFile)
    println(newFile, "<doStatement>")
    println(newFile, GetNextToken(tokens)) #<keyword> do </keyword>
    println(newFile, GetNextToken(tokens)) #<identifier> className/subRoutineName </identifier>
    subroutineCall(tokens, newFile)        # subroutineCall
    println(newFile, GetNextToken(tokens)) #<symbol> ; </symbol>
    println(newFile, "</doStatement>")
end


function ParseReturnStatement(tokens, newFile)
    println(newFile, "<returnStatement>")
    println(newFile, GetNextToken(tokens)) #<keyword> return </keyword>
    if !occursin( ";",CheckNextToken(tokens))
        ParseExpression(tokens, newFile)   # expression
    end
    println(newFile, GetNextToken(tokens)) #<symbol> ; </symbol>
    println(newFile, "</returnStatement>")
end


function ParseExpression(tokens, newFile)
    println(newFile, "<expression>")
    ParseTerm(tokens, newFile)   # term
    while occursin( " + ",CheckNextToken(tokens)) || occursin( " - ",CheckNextToken(tokens)) || occursin( " * ",CheckNextToken(tokens)) || occursin( " / ",CheckNextToken(tokens)) || occursin( "&amp;",CheckNextToken(tokens)) ||
        occursin( " | ",CheckNextToken(tokens))|| occursin( "&lt;",CheckNextToken(tokens)) || occursin( "&gt;",CheckNextToken(tokens)) || occursin( " = ",CheckNextToken(tokens))
        println(newFile, GetNextToken(tokens)) #<symbol> op </symbol>
        ParseTerm(tokens, newFile)
    end
    println(newFile, "</expression>")
end


function ParseTerm(tokens, newFile)
    println(newFile, "<term>")
    if  occursin( "stringConstant",CheckNextToken(tokens)) || occursin( "integerConstant",CheckNextToken(tokens))
        println(newFile, GetNextToken(tokens)) #/<integerConstant> integerConstant </integerConstant> /<stringConstant> stringConstant </stringConstant>
    elseif occursin( "true",CheckNextToken(tokens)) || occursin( "false",CheckNextToken(tokens)) || occursin( "null",CheckNextToken(tokens))|| occursin( "this",CheckNextToken(tokens))
        println(newFile, GetNextToken(tokens)) #<keyword> keywordConstant </keyword>
    elseif occursin( "identifier",CheckNextToken(tokens))
        println(newFile, GetNextToken(tokens)) #<identifier> varName / className / subRoutineName </identifier>
        if occursin( "[",CheckNextToken(tokens))
            println(newFile, GetNextToken(tokens)) #<symbol> [ </symbol>
            ParseExpression(tokens,newFile)    # expression
            println(newFile, GetNextToken(tokens)) #<symbol> ] </symbol>
        elseif occursin( "(",CheckNextToken(tokens)) || occursin( ".",CheckNextToken(tokens))
            subroutineCall(tokens, newFile)      #subroutineCall
        end
    elseif  occursin( "(",CheckNextToken(tokens))
        println(newFile, GetNextToken(tokens)) #<symbol> ( </symbol>
        ParseExpression(tokens,newFile)        # expression
        println(newFile, GetNextToken(tokens)) #<symbol> ) </symbol>
    elseif  occursin( "-",CheckNextToken(tokens)) ||  occursin( "~",CheckNextToken(tokens))   # unaryOp term
        println(newFile, GetNextToken(tokens)) #<symbol> -/~ </symbol>
        ParseTerm(tokens, newFile)             # term
    end
    println(newFile, "</term>")
end


function subroutineCall(tokens, newFile)
    if occursin( "(",CheckNextToken(tokens))
        println(newFile, GetNextToken(tokens)) #<symbol> ( </symbol>
        ParseExpressionList(tokens,newFile)    # expressionList
        println(newFile, GetNextToken(tokens)) #<symbol> ) </symbol>
    else
        println(newFile, GetNextToken(tokens)) #<symbol> . </symbol>
        println(newFile, GetNextToken(tokens)) #<identifier> subRoutineName </identifier>
        println(newFile, GetNextToken(tokens)) #<symbol> ( </symbol>
        ParseExpressionList(tokens,newFile)    # expressionList
        println(newFile, GetNextToken(tokens)) #<symbol> ) </symbol>
    end
end


function ParseExpressionList(tokens,newFile)
    println(newFile, "<expressionList>")
    while !occursin( ")",CheckNextToken(tokens))
        ParseExpression(tokens,newFile)     # expression
        while occursin( ",",CheckNextToken(tokens))
            println(newFile,  GetNextToken(tokens)) #<symbol>, </symbol>
            ParseExpression(tokens,newFile)
        end
    end
    println(newFile, "</expressionList>")
end





############ main ##############

global keyword=["class","constructor","function","method","field","static","let","do","if","else","while","return","var","int","char","boolean","void","true","false","null","this"]
global symbol=['{','}','(',')','[',']','.',',',';','+','-','*','/','&','|','<','>','=','~']  # all the symbols in jack
global index=1
println("Enter directory name: ")
path=readline()
arrOfPath=split(path, "\\")
files=readdir(path)
for file in files
    if endswith(file, ".jack")
        currentfile=open(path*'\\'*file, "r")    # currentfile is ->  main.jack
        file=SubString(file, 1, length(file)-5)   # file = name of the current jack file
        newFile=open(path*"\\"*file*"T.xml", "w")  # newfile is the tokenizer  
        println(newFile, "<tokens>")
        token=""
        while !eof(currentfile)
            token=token*string(read(currentfile, Char)) # connects(chain) all values ​​to a single string
            if token=="/"  && !eof(currentfile)
                token2=read(currentfile, Char)          # token2 is for a single char in currentfile
                if token2=='/' || token2=='*'   # comments in jack can look: // or /*
                    comments(token2, currentfile)
                else
                    symbols(token[end], currentfile, newFile)  # that mean it was one / therefor it`s a symbol
                    if isdigit(token2)
                        IntegerConstant(token2, currentfile, newFile)
                    elseif token2==' '
                        token=""                  # enter to token "" for initialization
                    else
                        identifier(token2, currentfile, newFile)
                    end
                end
            elseif all(isletter, token)         # check if the token is a letter
                letters(token, currentfile,newFile)

            elseif all(isdigit, token)         # check if the token is a letter
                IntegerConstant(token, currentfile,newFile)

            elseif token[end] in symbol 
                symbols(token[end], currentfile,newFile)

            elseif token[end]=='\"' && !eof(currentfile)    # refer to the " , in jack is quote -> stringConstant
                StringConstant(token, currentfile,newFile)

            elseif token[end]=='_' && !eof(currentfile)
                token=token*string(read(currentfile, Char))
                identifier(token, currentfile,newFile)

            elseif (token[end]=="\n"||token[end]=='\t'|| token[end]==' ') && !eof(currentfile)
                token=""                         # enter to token "" for initialization
            end
            token=""
        end
        println(newFile, "</tokens>")
        close(currentfile)  # currentfile is  -> main.jack
        close(newFile)      # newFile is      -> mainT.xml
        currentfile=open(path*"\\"*file*"T.xml", "r") # currentfile is  -> mainT.xml
        newFile=open(path*"\\"*file*".xml", "w")      # newFile is      -> main.xml
        tokens=readlines(currentfile)
        ParseClass(tokens, newFile)
        close(currentfile)
        close(newFile)
        global index=1
    end
end