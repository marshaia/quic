import aceEditor from "../vendor/ace_editor/ace.js"
import "../vendor/ace_editor/theme-one_dark"
import "../vendor/ace_editor/theme-xcode"
import "../vendor/ace_editor/mode-c_cpp"
import "../vendor/ace_editor/mode-python"

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

    loadingElement = document.getElementById(`${id}-loading`)
    if(loadingElement) loadingElement.classList.add("hidden")
    document.getElementById(id).classList.remove("hidden")

    this.handleEvent("clear_editor", () => {
      editor.setValue("")
    })
    this.handleEvent("change_language", (obj) => {
      language = obj.language
      if (language == "c") {
        editor.session.setMode("ace/mode/c_cpp");
      } else {
        editor.session.setMode("ace/mode/" + language);
      }
    }),

    editor.session.on('change', () => {
      const value = editor.getValue();
      
      if (id.includes("tests")) {
        this.pushEvent("update_parameter", { tests: value });
      } else if (id.includes("answers")) {
        this.pushEvent("update_parameter", { correct_answers: value });
      } else if (id.includes("file")) {
        this.pushEvent("update_parameter", { test_file: value });
      } else if (id.includes("participant-fill")) {
        const answer_id = id.split('-')[3];
        this.pushEvent("validate_participant_answer", { answer_id: answer_id, answer: value });
      } else if (id.includes("participant")) {
        this.pushEvent("validate_participant_answer", { answer: value });
      } else if (id.includes("code")) {
        this.pushEvent("update_parameter", { code: value });
      }
    });
  },
}