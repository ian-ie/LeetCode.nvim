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

M.CODE_TEMPLATE = [[
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

M.PROBLEM_CONTENT = [[
    query questionData($titleSlug: String!) {
        question(titleSlug: $titleSlug) {
            questionId
            questionFrontendId
            title: translatedTitle
            content: translatedContent
        }
    }
]]

M.TODAY_PROBLEM = [[
    query questionOfToday {
        todayRecord {
            question {
                frontendQuestionId: questionFrontendId
                slug: titleSlug
            }
        }
    }
]]

return M
