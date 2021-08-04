import { LightningElement } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";

export default class LeadFileImport extends LightningElement {
  objApiName = "Account";
  columnsMap = {
    COL1: "Name",
    COL2: "Type",
    COL3: "Phone"
  };
  isDisabled = true;

  handleReading(event) {
    var detail = event.detail;
    var obj = JSON.parse(detail);
    console.log(obj);
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  get options() {
    return [
      { label: "A", value: "A" },
      { label: "B", value: "B" },
      { label: "C", value: "C" },
      { label: "D", value: "D" },
      { label: "E", value: "E" },
      { label: "F", value: "F" },
      { label: "G", value: "G" },
      { label: "H", value: "H" },
      { label: "I", value: "I" },
      { label: "J", value: "J" }
    ];
  }

  handleChange(event) {
    if (event.detail.value !== "") {
      this.isDisabled = false;
    }
  }
}
