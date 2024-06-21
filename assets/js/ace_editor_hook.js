import aceEditor from "../vendor/ace_editor/ace.js"
import "../vendor/ace_editor/theme-one_dark"
import "../vendor/ace_editor/theme-xcode"
import "../vendor/ace_editor/mode-c_cpp"

function mount_editor(id) {
  var editor = aceEditor.edit(id, {minLines: 5, maxLines: 20, fontSize: 15});
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
      // document.getElementById(`${id}-code`).value = editor.getValue();
      if (id.includes("question")) {
        this.pushEvent("update_code_question", {code: editor.getValue()})
      } else {
        this.pushEvent("update_code_answer", {answer: editor.getValue()})
      }
    });
  },
}