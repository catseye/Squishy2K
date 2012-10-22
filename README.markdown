Squishky2K
==========

This is the reference distribution for the esoteric programming language
Squishy2K.

Here is a copy of the email that announced its creation.  That's all the
docs you get for now.

    .....Subject: [Esoteric] [Languages] New! Squishy2K (v2000.10.06)
            Date: Fri, 06 Oct 2000 20:56:43 -0500
            From: Chris Pressey
    Organization: Cat's Eye Technologies
              To: Cat's Eye Technologies Mailing List


    Back in ancient history I came up with a language which worked like a
    Turing-Complete EBNF - a compiler-compiler that could also do banal
    computation via translation.  I wanted to call the language Wirth in
    honour of the inventor of EBNF.  But the name SQUISHY was proposed and
    stuck.

    SQUISHY is now left to the sands of time, and this was long before I had
    ever heard of a semi-Thue grammar or the language Thue.

    But SQUISHY is now back, refurbished for the twenty-first century, in
    the form of Squishy2K!  Squishy2K is a lot like the original SQUISHY
    except with more and less.  It's not as much like EBNF anymore.  On the
    other hand, it's more like a state machine now!  And in Perl it's dead
    simple, something like 7K of code.

    Squishy2K is a string-rewriting language (read: Thue) embedded within a
    state machine (read: beta-Juliet) with states-doubling-as-functions
    thrown in for good measure (read: I haven't rhe foggiest idea what I'm
    doing.)

    Reading the grammar will prove to you how simple it is.

      Program ::= {State}.
      State   ::= "*" Name "{" {Rule} ["!" Name] "}".
      Rule    ::= LString "?" RString "!" [Name].
      LString ::= {quoted | "few" | "many" | "start" | "finish"}.
      RString ::= {quoted | digit | Name "(" RString ")"}.

    In English... a program consists of any number of states.  Each state
    begins with an asterisk, gives a name (alphanumeric), and contains any
    number of rules and an optional notwithstanding clause between curly
    braces.  The state named "main" is where flow control begins and ends.

    Each rule is composed of an "lstring" (a pattern to be searched for) and
    an "rstring" (an expression to replace any matched pattern with.)  The
    pattern tokens "start" and "finish" match the beginning and the end of
    the input string respectively.  The tokens "few" and "many" match any
    number of characters, the former preferring to match as few as possible,
    the latter is "greedy."  In the rstring, backreferences to the few and
    many tokens may be made with digits: 1 indicates the first few or many,
    2 the second, and so on.

    Each rule, and the notwithstanding clause, can name another state, and
    when a match succeeds on that rule (or no match succeeds for the
    notwithstanding clause), a transition along the arc to that state fires
    (i.e. it's a goto...)

    That's about it.

    Now I have to write a fake infomercial for it, and it'll be complete. 
    :-)

    _chris

    -- 
    Uryc! V'z genccrq vafvqr gur ebg13 plcure!
    Share and Enjoy on Cat's Eye Technologies' Electronic Mailing List
    http://www.catseye.mb.ca/list.html
