local M = {}
M.GLOBAL_DATA = [[
    query globalData {
        userStatus {
            isSignedIn
            username
        }
    }
]]

M.PROBLEMSET_QUESTION_LIST = [[
    query problemsetQuestionList($searchKeyword: String!){
        problemsetQuestionList(
            categorySlug: ""
            filters: {searchKeywords: $searchKeyword}
            limit: 20
            skip: 0
        ){
            total
            questions {
                paidOnly
                titleCn
                frontendQuestionId
                difficulty
                isFavor
                status
                titleSlug
            }
        }
    }
]]

M.QUESTION_DATA = [[
    query questionData($titleSlug: String!) {
        question(titleSlug: $titleSlug) {
            sampleTestCase
            codeSnippets {
                langSlug
                code
            }
        }
    }
]]
return M
