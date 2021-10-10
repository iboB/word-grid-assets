OUT_DIR = 'build'

###
# Load 3of6all and filter out
# * Short words < 3
# * Long words > 16
# * Phrases and phrasal verbs (with space)
# * Caps different than plain capitalization (proper names)
# * Shorst forms and abbreviations (contain '.')
#
# Also check special suffixes
# ^ - rare variants - keep
# ; - phrasal verbs - remove but don't take special care about ; as phrasal verbs have a space anyway
# & - Brittish spelling - keep
# $ - Rare forms - remove
# : - abbreviation - remove
# > - only in specific phrases - keep
# + - signature phrase - remove but again, those contain spaces, so they will be fixed earlier
#
# Also if a word appears twice with a capitalized and a non-capitalized form, the non-capitalized wins
# as it's likely to be more common
# Here make use of the fact in such a case in 3of6all the capitalized word immediately follows the
# non-capitalized one
#



