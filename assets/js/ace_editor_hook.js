import aceEditor from "../vendor/ace_editor/ace.js"
import "../vendor/ace_editor/theme-one_dark"
import "../vendor/ace_editor/theme-xcode"
import "../vendor/ace_editor/mode-c_cpp"

function mount_editor(id) {
  var editor = aceEditor.edit(id, {minLines: 3, maxLines: 20, fontSize: 15, showPrintMargin: false});
  if (document.documentElement.classList.contains('dark')) {
    editor.setTheme("ace/theme/one_dark");
  } else {
    editor.setTheme("ace/theme/xcode");
  }
  editor.session.setMode("ace/mode/c_cpp");
  editor.session.setTabSize(2);
  return editor
}

export const AceEditorHook = {
  mounted() {
    let id = this.el.id
    let editor = mount_editor(id);

    document.getElementById(`${id}-loading`).classList.add("hidden")
    document.getElementById(`${id}`).classList.remove("hidden")

    editor.session.on('change', () => {
      if (id.includes("tests")) {
        this.pushEvent("update_parameter", {tests: editor.getValue()})
      } else {
        if (id.includes("answers")) {
          this.pushEvent("update_parameter", {correct_answers: editor.getValue()})
        } else {
          if (id.includes("file")) {
            this.pushEvent("update_parameter", {test_file: editor.getValue()})
          } else {
            if (id.includes("participant-fill")) {
              answer_id = id.split('-')[3]
              this.pushEvent("validate_participant_answer", {answer_id: answer_id, answer: editor.getValue()})
            } else {
              if (id.includes("participant")) {
              this.pushEvent("validate_participant_answer", {answer: editor.getValue()})
            } else {
              if (id.includes("code")) {
                this.pushEvent("update_parameter", {code: editor.getValue()})
              } 
            }
            }
            
          }
        }
      }
    });
  },
}