import { Button, DatePicker, Form, Input, message, Modal } from "antd";
import { FormComponentProps } from "antd/lib/form";
import * as React from "react";
import Api from "../../api/Api";
import MatchRequests from "../../api/requests/MatchRequests";
import TournamentRequests from "../../api/requests/TournamentRequests";
import { IMatch } from "../../entities/IMatch";
import ITournament from "../../entities/ITournament";
import { GeneralEvents } from "../../events/GeneralEvents";
import { authenticated } from "../../helpers/AuthenticationHOC";
import TournamentContext from "./TournamentContext";

interface IAddButtonState {
  isModalOpen: boolean;
  isWorking: boolean;
}

interface IAddButtonProps extends FormComponentProps {
  tournamentId?: number;
}

class AddMatchButton extends React.Component<IAddButtonProps, IAddButtonState> {
  public static contextType = TournamentContext;

  public state: IAddButtonState = {
    isModalOpen: false,
    isWorking: false,
  };

  public render() {
    const { isModalOpen, isWorking } = this.state;
    const { getFieldDecorator } = this.props.form;

    return (
      <Button type="primary" className="w-100 p-0" title="Create tournament" onClick={this.onAdd}>
        <span><i className="material-icons">add</i> Add match</span>

        <Modal
          destroyOnClose={true}
          closable={true}
          maskClosable={false}
          visible={isModalOpen}
          onCancel={this.onCancel}
          onOk={this.onCreate}
          confirmLoading={isWorking}
          title="Create tournament"
        >
          <Form onSubmit={this.onCreate}>
            <Form.Item label="Match name">
              {
                getFieldDecorator(
                  "roundName",
                  { rules: [{ required: true, message: "Match name is required" }] },
                )(<Input placeholder="Match name" />)
              }
            </Form.Item>
            <Form.Item label="osu! multiplayer ID">
              {
                getFieldDecorator(
                  "matchId",
                  {
                    getValueFromEvent: (e: any) => parseInt(e.target.value, 10),
                    rules: [{ type: "number", required: true, message: "Match ID is required" }],
                  },
                )(<Input type="number" placeholder="osu! multiplayer ID" />)
              }
            </Form.Item>
            <Form.Item label="Discard list">
              {
                getFieldDecorator(
                  "discardList",
                  {
                    getValueFromEvent: (e: any) => (e.target.value || "").split("|"),
                    getValueProps: (value: string[]) => (value ?? []).join("|"),
                    rules: [{ type: "array" }],
                  },
                )(<Input type="text" placeholder="0|1|3..." />)
              }
            </Form.Item>
            <Form.Item label="Red team captain">
              {
                getFieldDecorator(
                  "redCaptain",
                  { rules: [{ required: true, message: "Red captain is required" }] },
                )(<Input type="text" placeholder="Player name or ID" />)
              }
            </Form.Item>
            <Form.Item label="Blue team captain">
              {
                getFieldDecorator(
                  "blueCaptain",
                  { rules: [{ required: true, message: "Blue captain is required" }] },
                )(<Input type="text" placeholder="Player name or ID" />)
              }
            </Form.Item>
            <Form.Item label="Referees">
              {
                getFieldDecorator(
                  "referees",
                  {
                    getValueFromEvent: (e: any) => (e.target.value || "").split("|"),
                    getValueProps: (value: string[]) => (value ?? []).join("|"),
                    rules: [{ type: "array" }],
                  },
                )(<Input type="text" placeholder="Potla|nitr0f|2" />)
              }
            </Form.Item>
          </Form>
        </Modal>
      </Button>
    );
  }

  private setModalVisibility = (visible: boolean) => this.setState({ isModalOpen: visible });

  private onAdd = (e: React.MouseEvent) => {
    e.stopPropagation();
    this.setModalVisibility(true);
  }

  private onCancel = (e: React.MouseEvent) => {
    e.stopPropagation();
    this.setModalVisibility(false);
  }

  private onCreate = async (e: React.MouseEvent | React.FormEvent) => {
    e.preventDefault();

    const { form } = this.props;

    const { error, values } = await new Promise(
      resolve => form.validateFieldsAndScroll((err, v) => resolve({ error: err, values: v })),
    );

    if (error) return;

    this.setState({ isWorking: true });

    try {
      if (this.context) values.tournamentId = this.context.id;

      const request = MatchRequests.createMatch(values);

      const response = await Api.performRequest<IMatch>(request);

      form.resetFields();
      this.setModalVisibility(false);

      $(document).trigger(GeneralEvents.MatchCreated, [response]);
      message.success(`${response.round_name} created!`);
    } catch (e) {
      message.error(e.message);
    } finally {
      this.setState({ isWorking: false });
    }
  }
}

const WrappedAddButtonForm = Form.create({ name: "add_match" })(AddMatchButton);

export default authenticated(WrappedAddButtonForm);
