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


return M
