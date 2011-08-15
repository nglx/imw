# -*- coding: utf-8 -*-
module Utf8TortureTest
  # ---------------------------------------------------------------------------
  #
  # 1.   Some correct UTF-8 text
  #
  #
  module SomeCorrectUTF8Text

    THE_GREEK_WORD_KOSME                 	= "\xCE\xBA\xE1\xBD\xB9\xCF\x83\xCE\xBC\xCE\xB5"
    INTERNATIONALIZATION_AS_STRING  = 'Iñtërnâtiônàlizætiøn'
    INTERNATIONALIZATION_AS_LITERAL = "I\xC3\xB1t\xC3\xABrn\xC3\xA2ti\xC3\xB4n\xC3\xA0liz\xC3\xA6ti\xC3\xB8n"
    
  end

  # ---------------------------------------------------------------------------
  #
  # 2.   Boundary condition test cases
  #
  #
  module BoundaryConditionTestCases

    #
    # 2.1. First possible sequence of a certain length
    #
    HAS_1_BYTE_U_00000000                	= "\x00"
    HAS_2_BYTES_U_00000080               	= "\xC2\x80"
    HAS_3_BYTES_U_00000800               	= "\xE0\xA0\x80"
    HAS_4_BYTES_U_00010000               	= "\xF0\x90\x80\x80"
    HAS_5_BYTES_U_00200000               	= "\xF8\x88\x80\x80\x80"
    HAS_6_BYTES_U_04000000               	= "\xFC\x84\x80\x80\x80\x80"

    #
    # 2.2. Last possible sequence of a certain length
    #
    HAS_1_BYTE_U_0000007F                	= "\x7F"
    HAS_2_BYTES_U_000007FF               	= "\xDF\xBF"
    HAS_3_BYTES_U_0000FFFF               	= "\xEF\xBF\xBF"
    HAS_4_BYTES_U_001FFFFF               	= "\xF7\xBF\xBF\xBF"
    HAS_5_BYTES_U_03FFFFFF               	= "\xFB\xBF\xBF\xBF\xBF"
    HAS_6_BYTES_U_7FFFFFFF               	= "\xFD\xBF\xBF\xBF\xBF\xBF"

    #
    # 2.3. Other boundary conditions
    #
    OTHER_BOUNDARY_CONDITIONS_ED_9F_BF   	= "\xED\x9F\xBF"
    OTHER_BOUNDARY_CONDITIONS_EE_80_80   	= "\xEE\x80\x80"
    OTHER_BOUNDARY_CONDITIONS_EF_BF_BD   	= "\xEF\xBF\xBD"
    OTHER_BOUNDARY_CONDITIONS_F4_8F_BF_BF	= "\xF4\x8F\xBF\xBF"
    OTHER_BOUNDARY_CONDITIONS_F4_90_80_80	= "\xF4\x90\x80\x80"
    
  end

  # ---------------------------------------------------------------------------
  #
  # 3.   Malformed sequences
  #
  #
  module MalformedSequences

    #
    # 3.1. Unexpected continuation bytes
    #
    #      Each unexpected continuation byte should be separately signalled as a
    #      malformed sequence of its own.
    #
    FIRST_CONTINUATION_BYTE_0X80         	= "\x80"
    LAST_CONTINUATION_BYTE_0XBF          	= "\xBF"
    HAS_2_CONTINUATION_BYTES             	= "\x80\xBF"
    HAS_3_CONTINUATION_BYTES             	= "\x80\xBF\x80"
    HAS_4_CONTINUATION_BYTES             	= "\x80\xBF\x80\xBF"
    HAS_5_CONTINUATION_BYTES             	= "\x80\xBF\x80\xBF\x80"
    HAS_6_CONTINUATION_BYTES             	= "\x80\xBF\x80\xBF\x80\xBF"
    HAS_7_CONTINUATION_BYTES             	= "\x80\xBF\x80\xBF\x80\xBF\x80"
    SEQUENCE_OF_ALL_64_POSSIBLE_CONTINUATION_BYTES_0X80_0XBF	= "\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF"

    #
    # 3.2. Lonely start characters
    #
    ALL_32_FIRST_BYTES_OF_2_BYTE_SEQUENCESEACH_FOLLOWED_BY_A_SPACE_CHARACTER_0XC0_0XDF	= "\xC0 \xC1 \xC2 \xC3 \xC4 \xC5 \xC6 \xC7 \xC8 \xC9 \xCA \xCB \xCC \xCD \xCE \xCF\xD0 \xD1 \xD2 \xD3 \xD4 \xD5 \xD6 \xD7 \xD8 \xD9 \xDA \xDB \xDC \xDD \xDE \xDF "
    ALL_16_FIRST_BYTES_OF_3_BYTE_SEQUENCESEACH_FOLLOWED_BY_A_SPACE_CHARACTER_0XE0_0XEF	= "\xE0 \xE1 \xE2 \xE3 \xE4 \xE5 \xE6 \xE7 \xE8 \xE9 \xEA \xEB \xEC \xED \xEE \xEF "
    ALL_8_FIRST_BYTES_OF_4_BYTE_SEQUENCESEACH_FOLLOWED_BY_A_SPACE_CHARACTER_0XF0_0XF7	= "\xF0 \xF1 \xF2 \xF3 \xF4 \xF5 \xF6 \xF7 "
    ALL_4_FIRST_BYTES_OF_5_BYTE_SEQUENCESEACH_FOLLOWED_BY_A_SPACE_CHARACTER_0XF8_0XFB	= "\xF8 \xF9 \xFA \xFB "
    ALL_2_FIRST_BYTES_OF_6_BYTE_SEQUENCESEACH_FOLLOWED_BY_A_SPACE_CHARACTER_0XFC_0XFD	= "\xFC \xFD "

    #
    # 3.3. Sequences with last continuation byte missing
    #
    #      All bytes of an incomplete sequence should be signalled as a single
    #      malformed sequence, i.e., you should see only a single replacement
    #      character in each of the next 10 tests. (Characters as in section 2)
    #
    HAS_2_BYTE_SEQUENCE_WITH_LAST_BYTE_MISSING_U_0000	= "\xC0"
    HAS_3_BYTE_SEQUENCE_WITH_LAST_BYTE_MISSING_U_0000	= "\xE0\x80"
    HAS_4_BYTE_SEQUENCE_WITH_LAST_BYTE_MISSING_U_0000	= "\xF0\x80\x80"
    HAS_5_BYTE_SEQUENCE_WITH_LAST_BYTE_MISSING_U_0000	= "\xF8\x80\x80\x80"
    HAS_6_BYTE_SEQUENCE_WITH_LAST_BYTE_MISSING_U_0000	= "\xFC\x80\x80\x80\x80"
    HAS_2_BYTE_SEQUENCE_WITH_LAST_BYTE_MISSING_U_000007FF	= "\xDF"
    HAS_3_BYTE_SEQUENCE_WITH_LAST_BYTE_MISSING_U_0000FFFF	= "\xEF\xBF"
    HAS_4_BYTE_SEQUENCE_WITH_LAST_BYTE_MISSING_U_001FFFFF	= "\xF7\xBF\xBF"
    HAS_5_BYTE_SEQUENCE_WITH_LAST_BYTE_MISSING_U_03FFFFFF	= "\xFB\xBF\xBF\xBF"
    HAS_6_BYTE_SEQUENCE_WITH_LAST_BYTE_MISSING_U_7FFFFFFF	= "\xFD\xBF\xBF\xBF\xBF"

    #
    # 3.4. Concatenation of incomplete sequences
    #
    #      All the 10 sequences of 3.3 concatenated, you should see 10 malformed
    #      sequences being signalled:
    #
    CONCATENATION_OF_INCOMPLETE_SEQUENCES	= "\xC0\xE0\x80\xF0\x80\x80\xF8\x80\x80\x80\xFC\x80\x80\x80\x80\xDF\xEF\xBF\xF7\xBF\xBF\xFB\xBF\xBF\xBF\xFD\xBF\xBF\xBF\xBF"

    #
    # 3.5. Impossible bytes
    #
    #      The following two bytes cannot appear in a correct UTF-8 string
    #
    IMPOSSIBLE_BYTES_FE                  	= "\xFE"
    IMPOSSIBLE_BYTES_FF                  	= "\xFF"
    IMPOSSIBLE_BYTES_FE_FE_FF_FF         	= "\xFE\xFE\xFF\xFF"
    
  end

  # ---------------------------------------------------------------------------
  #
  # 4.   Overlong sequences
  #
  #      The following sequences are not malformed according to the letter of
  #      the Unicode 2.0 standard. However, they are longer then necessary and
  #      a correct UTF-8 encoder is not allowed to produce them. A "safe UTF-8
  #      decoder" should reject them just like malformed sequences for two
  #      reasons: (1) It helps to debug applications if overlong sequences are
  #      not treated as valid representations of characters, because this helps
  #      to spot problems more quickly. (2) Overlong sequences provide
  #      alternative representations of characters, that could maliciously be
  #      used to bypass filters that check only for ASCII characters. For
  #      instance, a 2-byte encoded line feed (LF) would not be caught by a
  #      line counter that counts only 0x0a bytes, but it would still be
  #      processed as a line feed by an unsafe UTF-8 decoder later in the
  #      pipeline. From a security point of view, ASCII compatibility of UTF-8
  #      sequences means also, that ASCII characters are *only* allowed to be
  #      represented by ASCII bytes in the range 0x00-0x7f. To ensure this
  #      aspect of ASCII compatibility, use only "safe UTF-8 decoders" that
  #      reject overlong UTF-8 sequences for which a shorter encoding exists.
  #
  #
  module OverlongSequences

    #
    # 4.1. Examples of an overlong ASCII character
    #
    #      With a safe UTF-8 decoder, all of the following five overlong
    #      representations of the ASCII character slash ("/") should be rejected
    #      like a malformed UTF-8 sequence, for instance by substituting it with
    #      a replacement character. If you see a slash below, you do not have a
    #      safe UTF-8 decoder!
    #
    EXAMPLES_OF_AN_OVERLONG_ASCII_CHARACTER_C0_AF	= "\xC0\xAF"
    EXAMPLES_OF_AN_OVERLONG_ASCII_CHARACTER_E0_80_AF	= "\xE0\x80\xAF"
    EXAMPLES_OF_AN_OVERLONG_ASCII_CHARACTER_F0_80_80_AF	= "\xF0\x80\x80\xAF"
    EXAMPLES_OF_AN_OVERLONG_ASCII_CHARACTER_F8_80_80_80_AF	= "\xF8\x80\x80\x80\xAF"
    EXAMPLES_OF_AN_OVERLONG_ASCII_CHARACTER_FC_80_80_80_80_AF	= "\xFC\x80\x80\x80\x80\xAF"

    #
    # 4.2. Maximum overlong sequences
    #
    #      Below you see the highest Unicode value that is still resulting in an
    #      overlong sequence if represented with the given number of bytes. This
    #      is a boundary test for safe UTF-8 decoders. All five characters should
    #      be rejected like malformed UTF-8 sequences.
    #
    MAXIMUM_OVERLONG_SEQUENCES_C1_BF     	= "\xC1\xBF"
    MAXIMUM_OVERLONG_SEQUENCES_E0_9F_BF  	= "\xE0\x9F\xBF"
    MAXIMUM_OVERLONG_SEQUENCES_F0_8F_BF_BF	= "\xF0\x8F\xBF\xBF"
    MAXIMUM_OVERLONG_SEQUENCES_F8_87_BF_BF_BF	= "\xF8\x87\xBF\xBF\xBF"
    MAXIMUM_OVERLONG_SEQUENCES_FC_83_BF_BF_BF_BF	= "\xFC\x83\xBF\xBF\xBF\xBF"

    #
    # 4.3. Overlong representation of the NUL character
    #
    #      The following five sequences should also be rejected like malformed
    #      UTF-8 sequences and should not be treated like the ASCII NUL
    #      character.
    #
    OVERLONG_REPRESENTATION_OF_THE_NUL_CHARACTER_C0_80	= "\xC0\x80"
    OVERLONG_REPRESENTATION_OF_THE_NUL_CHARACTER_E0_80_80	= "\xE0\x80\x80"
    OVERLONG_REPRESENTATION_OF_THE_NUL_CHARACTER_F0_80_80_80	= "\xF0\x80\x80\x80"
    OVERLONG_REPRESENTATION_OF_THE_NUL_CHARACTER_F8_80_80_80_80	= "\xF8\x80\x80\x80\x80"
    OVERLONG_REPRESENTATION_OF_THE_NUL_CHARACTER_FC_80_80_80_80_80	= "\xFC\x80\x80\x80\x80\x80"
    
  end

  # ---------------------------------------------------------------------------
  #
  # 5.   Illegal code positions
  #
  #      The following UTF-8 sequences should be rejected like malformed
  #      sequences, because they never represent valid ISO 10646 characters and
  #      a UTF-8 decoder that accepts them might introduce security problems
  #      comparable to overlong UTF-8 sequences.
  #
  #
  module IllegalCodePositions

    #
    # 5.1. Single UTF-16 surrogates
    #
    SINGLE_UTF_16_SURROGATES_ED_A0_80    	= "\xED\xA0\x80"
    SINGLE_UTF_16_SURROGATES_ED_AD_BF    	= "\xED\xAD\xBF"
    SINGLE_UTF_16_SURROGATES_ED_AE_80    	= "\xED\xAE\x80"
    SINGLE_UTF_16_SURROGATES_ED_AF_BF    	= "\xED\xAF\xBF"
    SINGLE_UTF_16_SURROGATES_ED_B0_80    	= "\xED\xB0\x80"
    SINGLE_UTF_16_SURROGATES_ED_BE_80    	= "\xED\xBE\x80"
    SINGLE_UTF_16_SURROGATES_ED_BF_BF    	= "\xED\xBF\xBF"

    #
    # 5.2. Paired UTF-16 surrogates
    #
    PAIRED_UTF_16_SURROGATES_ED_A0_80_ED_B0_80	= "\xED\xA0\x80\xED\xB0\x80"
    PAIRED_UTF_16_SURROGATES_ED_A0_80_ED_BF_BF	= "\xED\xA0\x80\xED\xBF\xBF"
    PAIRED_UTF_16_SURROGATES_ED_AD_BF_ED_B0_80	= "\xED\xAD\xBF\xED\xB0\x80"
    PAIRED_UTF_16_SURROGATES_ED_AD_BF_ED_BF_BF	= "\xED\xAD\xBF\xED\xBF\xBF"
    PAIRED_UTF_16_SURROGATES_ED_AE_80_ED_B0_80	= "\xED\xAE\x80\xED\xB0\x80"
    PAIRED_UTF_16_SURROGATES_ED_AE_80_ED_BF_BF	= "\xED\xAE\x80\xED\xBF\xBF"
    PAIRED_UTF_16_SURROGATES_ED_AF_BF_ED_B0_80	= "\xED\xAF\xBF\xED\xB0\x80"
    PAIRED_UTF_16_SURROGATES_ED_AF_BF_ED_BF_BF	= "\xED\xAF\xBF\xED\xBF\xBF"

    #
    # 5.3. Other illegal code positions
    #
    OTHER_ILLEGAL_CODE_POSITIONS_EF_BF_BE	= "\xEF\xBF\xBE"
    OTHER_ILLEGAL_CODE_POSITIONS_EF_BF_BF	= "\xEF\xBF\xBF"
    
  end


end
if $0 == __FILE__ then Utf8TortureTest::SomeCorrectUTF8Text.constants.each{|str| puts Utf8TortureTest::SomeCorrectUTF8Text.const_get(str) } ; end
