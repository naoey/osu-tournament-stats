import { Button } from "antd";
import * as React from "react";
import { authenticated } from "../../helpers/AuthenticationHOC";

class AddButton extends React.Component {
  public render() {
    return (
      <Button type="primary" className="w-100" onClick={this.onAdd}>
        <i className="material-icons">add</i>
        <span>Add tournament</span>
      </Button>
    );
  }

  private onAdd = () => {
    console.log("Adding new tournament");
  }
}

export default authenticated(AddButton);
