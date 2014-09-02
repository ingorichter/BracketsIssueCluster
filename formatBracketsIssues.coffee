fs = require 'fs'
_ = require 'lodash'
es6shim = require 'es6-shim'

bracketsIssuesFor10 = ""
data = ""

PrioLabels = {
  "HIGH": "high priority",
  "MEDIUM": "medium priority",
  "LOW": "low priority"
}

readData = () ->
  new Promise((resolve, reject) ->
    if process.argv.length > 3 && process.argv[3] is "-"
      process.stdin.on "readable", () ->
        chunk = process.stdin.read()
        if chunk
          data += chunk

      process.stdin.on "end", () ->
        bracketsIssuesFor10 = JSON.parse data
        resolve()
    else
      fs.readFile "brackets-issues.json", (err, data) ->
        if (err)
          reject(err)
        bracketsIssuesFor10 = JSON.parse data
        resolve()
  )

writeReport = () ->
  # get all issues
  labels2Issues = {}
  _.forEach bracketsIssuesFor10, (issue) ->
    _.forEach issue.labels, (label) ->
      labels2Issues[label.name] = [] if !labels2Issues[label.name]
      labels2Issues[label.name].push issue

  issuesWithoutPriority = bracketsIssuesFor10.length - (labels2Issues[PrioLabels.HIGH].length + labels2Issues[PrioLabels.MEDIUM].length + labels2Issues[PrioLabels.LOW].length)

  console.log "Issue Clusters 1.0 Milestone"
  console.log "============================"
  console.log "#{bracketsIssuesFor10.length} open issues #{new Date()}"
  console.log "\n"
  console.log "Issues appear in multiple cluster. **Bold** issues don't have a priority assigned."
  console.log "\n"
  console.log "Priorities"
  console.log "=========="
  console.log "- #{labels2Issues['high priority'].length} high priority"
  console.log "- #{labels2Issues['medium priority'].length} medium priority"
  console.log "- #{labels2Issues['low priority'].length} low priority"
  console.log "- %s issues without priority", issuesWithoutPriority if issuesWithoutPriority > 0
  console.log "\n\n"

  console.log "# Issues by Category"

  allLabels = Object.keys(labels2Issues)

  allLabels.sort (labela, labelb) ->
    labels2Issues[labelb].length - labels2Issues[labela].length

  hasLabelPredicate = (label) ->
    label.name is PrioLabels.HIGH or
    label.name is PrioLabels.MEDIUM or
    label.name is PrioLabels.LOW

  _.forEach allLabels, (label, labelname) ->
    console.log "## #{label} #{labels2Issues[label].length}"
    _.forEach labels2Issues[label], (issue) ->
      hasPrio = _.some issue.labels, hasLabelPredicate
      console.log "- #{if hasPrio then "" else "**"}[#{issue.title}](#{issue.html_url})#{if hasPrio then "" else "**"}"
    console.log ""

readData().then () ->
  writeReport()
